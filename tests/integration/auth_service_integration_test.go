package integration

import (
	"context"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"outfitstyle/server/internal/core/application/services"
	"outfitstyle/server/internal/core/domain"
	"outfitstyle/server/internal/infrastructure/persistence/postgres"
	"outfitstyle/server/internal/infrastructure/persistence/postgres/pg"
)

// Alias для совместимости
type DB = postgres.DB

// Эти тесты требуют запущенной базы данных
func TestAuthService_Integration(t *testing.T) {
	// Пропустить тест, если нет базы данных
	if testing.Short() {
		t.Skip("Skipping integration test")
	}

	// Подключение к тестовой базе данных
	db, err := ConnectTestDB()
	require.NoError(t, err)
	defer db.Close()

	// Создание реальных репозиториев
	userRepo := pg.NewUserRepository(db.Pool(), nil)
	sessionRepo := pg.NewSessionRepository(db.Pool(), nil)

	// Создание сервиса с реальными зависимостями
	authService := services.NewAuthService(userRepo, sessionRepo, nil, nil)

	t.Run("Register and Login", func(t *testing.T) {
		// Подготовка
		ctx := context.Background()
		email := "integration_test@example.com"
		password := "password123"

		// Регистрация
		registerInput := domain.UserRegistration{
			Email:    email,
			Password: password,
		}

		registerResult, err := authService.Register(ctx, registerInput, services.DeviceInfo{})
		require.NoError(t, err)
		require.NotNil(t, registerResult.User)

		// Проверка, что пользователь создан
		user, err := userRepo.GetUserByEmail(ctx, email)
		require.NoError(t, err)
		require.NotNil(t, user)
		assert.Equal(t, email, user.Email)

		// Логин
		loginInput := domain.UserLogin{
			Email:    email,
			Password: password,
		}

		loginResult, err := authService.Login(ctx, loginInput, services.DeviceInfo{})
		assert.NoError(t, err)
		assert.NotNil(t, loginResult.User)
		assert.NotEmpty(t, loginResult.Tokens.AccessToken)
		assert.NotEmpty(t, loginResult.Tokens.RefreshToken)

		// Очистка
		err = userRepo.DeleteUser(ctx, user.ID)
		require.NoError(t, err)
	})

	t.Run("Duplicate Registration", func(t *testing.T) {
		// Подготовка
		ctx := context.Background()
		email := "duplicate_test@example.com"
		password := "password123"

		// Первичная регистрация
		registerInput := domain.UserRegistration{
			Email:    email,
			Password: password,
		}

		_, err := authService.Register(ctx, registerInput, services.DeviceInfo{})
		require.NoError(t, err)

		// Попытка повторной регистрации
		_, err = authService.Register(ctx, registerInput, services.DeviceInfo{})
		assert.Error(t, err)

		// Очистка
		user, err := userRepo.GetUserByEmail(ctx, email)
		if err == nil && user != nil {
			err = userRepo.DeleteUser(ctx, user.ID)
			require.NoError(t, err)
		}
	})
}

// Вспомогательная функция для подключения к тестовой базе данных
// В реальном проекте эта функция будет в отдельном файле helpers.go
func ConnectTestDB() (*DB, error) {
	// Здесь будет реализация подключения к тестовой базе данных
	// В настоящем проекте использовать конфигурацию из тестового окружения
	return nil, nil
}