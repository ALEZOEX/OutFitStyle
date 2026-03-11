import { useState, useEffect } from 'react';
import {
  Moon, Sun, ChevronRight, CloudSun, CloudRain,
  Sparkles, Smartphone, WifiOff, Clock, Umbrella, Layers, ChevronDown
} from 'lucide-react';
import { HeroVisual } from './components/HeroVisual';
import { GlowCard } from './components/GlowCard';
import { Marquee } from './components/Marquee';
import { RevealText } from './components/RevealText';
import { Magnetic } from './components/Magnetic';
import logo from './assets/logo.png';

export function App() {
  const [isDark, setIsDark] = useState(false);
  const [isScrolled, setIsScrolled] = useState(false);

  useEffect(() => {
    const handleScroll = () => setIsScrolled(window.scrollY > 20);
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  useEffect(() => {
    if (localStorage.getItem('theme') === 'dark' ||
      (!('theme' in localStorage) && window.matchMedia('(prefers-color-scheme: dark)').matches)) {
      setIsDark(true);
      document.documentElement.classList.add('dark');
    } else {
      setIsDark(false);
      document.documentElement.classList.remove('dark');
    }
  }, []);

  const toggleTheme = () => {
    if (isDark) {
      document.documentElement.classList.remove('dark');
      localStorage.setItem('theme', 'light');
      setIsDark(false);
    } else {
      document.documentElement.classList.add('dark');
      localStorage.setItem('theme', 'dark');
      setIsDark(true);
    }
  };

  return (
    <div className="min-h-screen bg-[#fafafa] dark:bg-[#090a0f] text-gray-900 dark:text-gray-100 font-sans transition-colors duration-500 selection:bg-primary-500/30 overflow-hidden relative">

      {/* Background Noise Texture (Subtle) */}
      <div className="pointer-events-none fixed inset-0 z-50 opacity-[0.015] dark:opacity-[0.03]"
        style={{ backgroundImage: 'url("data:image/svg+xml,%3Csvg viewBox=%220 0 200 200%22 xmlns=%22http://www.w3.org/2000/svg%22%3E%3Cfilter id=%22noiseFilter%22%3E%3CfeTurbulence type=%22fractalNoise%22 baseFrequency=%220.65%22 numOctaves=%223%22 stitchTiles=%22stitch%22/%3E%3C/filter%3E%3Crect width=%22100%25%22 height=%22100%25%22 filter=%22url(%23noiseFilter)%22/%3E%3C/svg%3E")' }}>
      </div>

      {/* Floating Animated Orbs */}
      <div className="fixed inset-0 overflow-hidden pointer-events-none z-0">
        <div className="absolute top-[-10%] left-[-10%] w-[40%] h-[40%] rounded-full bg-primary-400/20 dark:bg-primary-600/20 blur-[120px] mix-blend-multiply dark:mix-blend-screen animate-blob" />
        <div className="absolute top-[20%] right-[-10%] w-[50%] h-[50%] rounded-full bg-accent-400/20 dark:bg-accent-600/20 blur-[120px] mix-blend-multiply dark:mix-blend-screen animate-blob animation-delay-2000" />
        <div className="absolute bottom-[-20%] left-[20%] w-[60%] h-[60%] rounded-full bg-blue-400/20 dark:bg-blue-600/20 blur-[120px] mix-blend-multiply dark:mix-blend-screen animate-blob animation-delay-4000" />
      </div>

      {/* Navigation */}
      <nav className={`fixed top-0 left-0 right-0 z-50 transition-all duration-300 ${isScrolled ? 'glass-header py-2 sm:py-3' : 'bg-transparent py-3 sm:py-5'}`}>
        <div className="max-w-7xl mx-auto px-3 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center">
            <div className="flex items-center gap-2 sm:gap-3 group cursor-pointer">
              <div className="w-8 h-8 sm:w-10 sm:h-10 rounded-xl overflow-hidden shadow-lg shadow-primary-500/20 group-hover:shadow-primary-500/40 transition-shadow">
                <img src={logo} alt="OutfitStyle" className="w-full h-full object-cover" />
              </div>
              <span className="text-lg sm:text-xl font-bold tracking-tight">OutfitStyle</span>
            </div>

            <div className="hidden md:flex items-center gap-8 font-medium text-sm text-gray-600 dark:text-gray-300">
              <a href="#features" className="hover:text-primary-600 dark:hover:text-primary-400 transition-colors">Преимущества</a>
              <a href="#how-it-works" className="hover:text-primary-600 dark:hover:text-primary-400 transition-colors">Как это работает</a>
              <a href="#examples" className="hover:text-primary-600 dark:hover:text-primary-400 transition-colors">Примеры</a>
            </div>

            <div className="flex items-center gap-2 sm:gap-4">
              <button
                onClick={toggleTheme}
                className="w-9 h-9 sm:w-10 sm:h-10 rounded-full flex items-center justify-center hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors border border-transparent dark:border-gray-800"
                aria-label="Toggle theme"
              >
                {isDark ? <Sun className="w-4 h-4 sm:w-5 sm:h-5" /> : <Moon className="w-4 h-4 sm:w-5 sm:h-5" />}
              </button>
              <div className="hidden sm:block">
                <Magnetic>
                  <a href="#download" className="px-4 sm:px-5 py-2 sm:py-2.5 bg-gray-900 dark:bg-white text-white dark:text-gray-900 text-xs sm:text-sm font-semibold rounded-full hover:scale-105 transition-transform shadow-lg shadow-gray-900/20 dark:shadow-white/20 inline-block">
                    Скачать
                  </a>
                </Magnetic>
              </div>
            </div>
          </div>
        </div>
      </nav>

      <main className="relative z-10 pt-32 pb-20">

        {/* Hero Section */}
        <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 flex flex-col lg:flex-row items-center gap-16 min-h-[80vh]">
          <div className="flex-1 text-center lg:text-left z-20">
            <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full border border-gray-200 dark:border-gray-800 bg-white/50 dark:bg-gray-900/50 backdrop-blur-md mb-8 animate-fade-in-up">
              <span className="relative flex h-2 w-2">
                <span className="absolute inline-flex h-full w-full rounded-full bg-primary-400 opacity-60 blur-[2px]"></span>
                <span className="relative inline-flex rounded-full h-2 w-2 bg-primary-500"></span>
              </span>
              <span className="text-xs font-semibold uppercase tracking-wider text-gray-600 dark:text-gray-300">Умный подбор одежды</span>
            </div>

            <h1 className="text-5xl sm:text-7xl font-extrabold tracking-tight mb-6 leading-tight animate-fade-in-up" style={{ animationDelay: '0.1s' }}>
              Ваш идеальный <br />
              <span className="gradient-text">образ за секунды</span>
            </h1>

            <p className="text-lg sm:text-xl text-gray-600 dark:text-gray-400 mb-10 max-w-2xl mx-auto lg:mx-0 animate-fade-in-up leading-relaxed" style={{ animationDelay: '0.2s' }}>
              Нейросеть проанализирует ваш гардероб, текущую погоду за окном и повод, чтобы собрать безупречный наряд. Забудьте о проблеме «Мне нечего надеть».
            </p>

            <div className="flex flex-col sm:flex-row items-center justify-center lg:justify-start gap-4 animate-fade-in-up" style={{ animationDelay: '0.3s' }}>
              <Magnetic>
                <a href="#download" className="group relative px-8 py-4 bg-gray-900 dark:bg-white text-white dark:text-gray-900 font-semibold rounded-full overflow-hidden shadow-xl shadow-gray-900/20 dark:shadow-white/20 flex items-center justify-center">
                  <div className="absolute inset-0 w-full h-full bg-gradient-to-r from-transparent via-white/20 dark:via-black/10 to-transparent -translate-x-full group-hover:animate-[shimmer_1.5s_infinite]" />
                  <span className="relative flex items-center gap-2">
                    Скачать бесплатно <ChevronRight className="w-4 h-4 group-hover:translate-x-1 transition-transform" />
                  </span>
                </a>
              </Magnetic>
              <a href="#features" className="px-8 py-4 bg-white/50 dark:bg-gray-800/50 backdrop-blur-md border border-gray-200 dark:border-gray-700 font-semibold rounded-full hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors flex items-center justify-center gap-2">
                Как это работает?
              </a>
            </div>

            {/* Статистика удалена для честности позиционирования */}
          </div>

          <div className="flex-1 w-full lg:w-auto mt-12 lg:mt-0 relative z-20 animate-fade-in-up" style={{ animationDelay: '0.5s' }}>
            <HeroVisual />
          </div>
        </section>

        {/* Style Tag Marquee */}
        <Marquee />

        {/* Core Features / Consumer Bento */}
        <section id="features" className="py-12 sm:py-20 lg:py-24 px-3 sm:px-6 lg:px-8 relative z-20">
          <div className="max-w-7xl mx-auto">
            <RevealText text="Магия технологий для вашего стиля" className="text-2xl sm:text-4xl lg:text-5xl font-extrabold text-center mb-3 sm:mb-4 text-gray-900 dark:text-white tracking-tight px-2" />
            <p className="text-center text-base sm:text-lg lg:text-xl text-gray-600 dark:text-gray-400 mb-8 sm:mb-12 lg:mb-16 max-w-3xl mx-auto px-4">
              Мы объединили мощный искусственный интеллект с элегантным интерфейсом, чтобы каждое утро начиналось идеально.
            </p>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 sm:gap-6">

              <GlowCard className="lg:col-span-2">
                <div className="flex flex-col md:flex-row items-center gap-8">
                  <div className="flex-1">
                    <div className="w-12 h-12 rounded-2xl bg-blue-100 dark:bg-blue-900/30 flex items-center justify-center mb-6">
                      <CloudSun className="w-6 h-6 text-blue-600 dark:text-blue-400" />
                    </div>
                    <h3 className="text-2xl font-bold mb-3">Синхронизация с погодой</h3>
                    <p className="text-gray-600 dark:text-gray-400 leading-relaxed">
                      Приложение знает, когда пойдет дождь или поднимется ветер. Получайте рекомендации, которые не только стильно выглядят, но и идеально подходят под текущую температуру за окном.
                    </p>
                  </div>
                  <div className="flex-1 w-full relative h-48 bg-gray-50 dark:bg-gray-900 rounded-xl border border-gray-200 dark:border-gray-800 flex items-center justify-center overflow-hidden">
                    <div className="absolute inset-0 bg-gradient-to-tr from-blue-500/10 to-transparent"></div>
                    <div className="relative z-10 flex gap-4 items-center flex-col sm:flex-row">
                      <div className="px-5 py-3 bg-white dark:bg-gray-800 rounded-2xl shadow-xl border border-gray-200/50 dark:border-gray-700/50 text-center">
                        <CloudRain className="w-8 h-8 text-blue-500 mx-auto mb-2" />
                        <div className="font-bold text-lg">14°C</div>
                        <div className="text-xs text-gray-500">Дождь через час</div>
                      </div>
                      <ChevronRight className="w-6 h-6 text-gray-400 hidden sm:block" />
                      <div className="px-5 py-3 bg-blue-500 text-white rounded-2xl shadow-xl shadow-blue-500/30 text-center">
                        <Umbrella className="w-8 h-8 mx-auto mb-2" />
                        <div className="font-bold text-lg">Тренч + Зонт</div>
                        <div className="text-xs text-blue-100">Идеальный выбор</div>
                      </div>
                    </div>
                  </div>
                </div>
              </GlowCard>

              <GlowCard>
                <div className="w-12 h-12 rounded-2xl bg-pink-100 dark:bg-pink-900/30 flex items-center justify-center mb-6">
                  <Sparkles className="w-6 h-6 text-pink-600 dark:text-pink-400" />
                </div>
                <h3 className="text-xl font-bold mb-3">Обучается вашему вкусу</h3>
                <p className="text-gray-600 dark:text-gray-400 text-sm leading-relaxed">
                  Чем чаще вы пользуетесь приложением, тем точнее нейросеть понимает, какие цвета, фасоны и бренды вы предпочитаете.
                </p>
              </GlowCard>

              <GlowCard>
                <div className="w-12 h-12 rounded-2xl bg-emerald-100 dark:bg-emerald-900/30 flex items-center justify-center mb-6">
                  <Smartphone className="w-6 h-6 text-emerald-600 dark:text-emerald-400" />
                </div>
                <h3 className="text-xl font-bold mb-3">Оцифровка гардероба</h3>
                <p className="text-gray-600 dark:text-gray-400 text-sm leading-relaxed">
                  Просто добавьте свои вещи, и мы создадим из них тысячи новых комбинаций на каждый день.
                </p>
              </GlowCard>

              <GlowCard>
                <div className="w-12 h-12 rounded-2xl bg-purple-100 dark:bg-purple-900/30 flex items-center justify-center mb-6">
                  <WifiOff className="w-6 h-6 text-purple-600 dark:text-purple-400" />
                </div>
                <h3 className="text-xl font-bold mb-3">Всегда с вами</h3>
                <p className="text-gray-600 dark:text-gray-400 text-sm leading-relaxed">
                  Полная поддержка оффлайн-режима. Собирайте образы в самолете или за городом без подключения к сети.
                </p>
              </GlowCard>

              <GlowCard>
                <div className="w-12 h-12 rounded-2xl bg-amber-100 dark:bg-amber-900/30 flex items-center justify-center mb-6">
                  <Clock className="w-6 h-6 text-amber-600 dark:text-amber-400" />
                </div>
                <h3 className="text-xl font-bold mb-3">Экономия времени</h3>
                <p className="text-gray-600 dark:text-gray-400 text-sm leading-relaxed">
                  Пользователи OutfitStyle экономят до 20 минут каждое утро, доверяя выбор одежды искусственному интеллекту.
                </p>
              </GlowCard>

            </div>
          </div>
        </section>

        {/* Examples Section */}
        <section id="examples" className="py-12 sm:py-20 lg:py-24 px-3 sm:px-6 lg:px-8 relative z-20">
          <div className="max-w-7xl mx-auto">
            <RevealText text="Примеры образов" className="text-2xl sm:text-4xl lg:text-5xl font-extrabold text-center mb-3 sm:mb-4 text-gray-900 dark:text-white tracking-tight px-2" />
            <p className="text-center text-base sm:text-lg lg:text-xl text-gray-600 dark:text-gray-400 mb-8 sm:mb-12 lg:mb-16 max-w-3xl mx-auto px-4">
              Смотрите, как нейросеть сочетает вещи из вашего гардероба для разных ситуаций
            </p>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 sm:gap-6">

              <GlowCard>
                <div className="w-full h-48 bg-gradient-to-br from-blue-100 to-blue-200 dark:from-blue-900/30 dark:to-blue-800/30 rounded-xl mb-4 flex items-center justify-center overflow-hidden">
                  <CloudSun className="w-16 h-16 text-blue-600 dark:text-blue-400" />
                </div>
                <h3 className="text-lg font-bold mb-2">Деловая встреча</h3>
                <p className="text-gray-600 dark:text-gray-400 text-sm">
                  Классический пиджак, белая рубашка, брюки чинос. Идеально для презентации проекта.
                </p>
              </GlowCard>

              <GlowCard>
                <div className="w-full h-48 bg-gradient-to-br from-emerald-100 to-emerald-200 dark:from-emerald-900/30 dark:to-emerald-800/30 rounded-xl mb-4 flex items-center justify-center overflow-hidden">
                  <Umbrella className="w-16 h-16 text-emerald-600 dark:text-emerald-400" />
                </div>
                <h3 className="text-lg font-bold mb-2">Прогулка в дождь</h3>
                <p className="text-gray-600 dark:text-gray-400 text-sm">
                  Водонепроницаемая куртка, удобные ботинки, вместительный рюкзак.
                </p>
              </GlowCard>

              <GlowCard>
                <div className="w-full h-48 bg-gradient-to-br from-pink-100 to-pink-200 dark:from-pink-900/30 dark:to-pink-800/30 rounded-xl mb-4 flex items-center justify-center overflow-hidden">
                  <Sparkles className="w-16 h-16 text-pink-600 dark:text-pink-400" />
                </div>
                <h3 className="text-lg font-bold mb-2">Вечеринка</h3>
                <p className="text-gray-600 dark:text-gray-400 text-sm">
                  Стильное платье, яркие аксессуары, удобная обувь для танцев.
                </p>
              </GlowCard>

            </div>
          </div>
        </section>

        {/* FAQ Section */}
        <section id="faq" className="py-12 sm:py-20 lg:py-24 px-3 sm:px-6 lg:px-8 relative z-20">
          <div className="max-w-3xl mx-auto">
            <RevealText text="Частые вопросы" className="text-2xl sm:text-4xl lg:text-5xl font-extrabold text-center mb-3 sm:mb-4 text-gray-900 dark:text-white tracking-tight px-2" />
            <p className="text-center text-base sm:text-lg lg:text-xl text-gray-600 dark:text-gray-400 mb-8 sm:mb-12 lg:mb-16 max-w-3xl mx-auto px-4">
              Ответы на популярные вопросы о приложении
            </p>

            <div className="space-y-3 sm:space-y-4">
              <details className="group bg-white/60 dark:bg-gray-800/40 backdrop-blur-xl rounded-xl sm:rounded-2xl border border-gray-200 dark:border-gray-700 overflow-hidden transition-all duration-300 hover:shadow-lg">
                <summary className="flex items-center justify-between p-4 sm:p-6 cursor-pointer font-semibold text-sm sm:text-base text-gray-900 dark:text-white">
                  Как работает приложение?
                  <ChevronDown className="w-4 h-4 sm:w-5 sm:h-5 transition-transform group-open:rotate-180 flex-shrink-0 ml-2" />
                </summary>
                <div className="px-4 sm:px-6 pb-4 sm:pb-6 text-sm sm:text-base text-gray-600 dark:text-gray-400">
                  Нейросеть анализирует ваш гардероб, текущую погоду и событие, чтобы предложить идеальный образ. Просто добавьте вещи в приложение и получайте рекомендации каждое утро.
                </div>
              </details>

              <details className="group bg-white/60 dark:bg-gray-800/40 backdrop-blur-xl rounded-xl sm:rounded-2xl border border-gray-200 dark:border-gray-700 overflow-hidden transition-all duration-300 hover:shadow-lg">
                <summary className="flex items-center justify-between p-4 sm:p-6 cursor-pointer font-semibold text-sm sm:text-base text-gray-900 dark:text-white">
                  Это бесплатно?
                  <ChevronDown className="w-4 h-4 sm:w-5 sm:h-5 transition-transform group-open:rotate-180 flex-shrink-0 ml-2" />
                </summary>
                <div className="px-4 sm:px-6 pb-4 sm:pb-6 text-sm sm:text-base text-gray-600 dark:text-gray-400">
                  Да, базовая версия приложения полностью бесплатна. Премиум-функции доступны по подписке и включают расширенные возможности персонализации.
                </div>
              </details>

              <details className="group bg-white/60 dark:bg-gray-800/40 backdrop-blur-xl rounded-xl sm:rounded-2xl border border-gray-200 dark:border-gray-700 overflow-hidden transition-all duration-300 hover:shadow-lg">
                <summary className="flex items-center justify-between p-4 sm:p-6 cursor-pointer font-semibold text-sm sm:text-base text-gray-900 dark:text-white">
                  Работает ли приложение без интернета?
                  <ChevronDown className="w-4 h-4 sm:w-5 sm:h-5 transition-transform group-open:rotate-180 flex-shrink-0 ml-2" />
                </summary>
                <div className="px-4 sm:px-6 pb-4 sm:pb-6 text-sm sm:text-base text-gray-600 dark:text-gray-400">
                  Приложение может работать без интернета для просмотра загруженного гардероба. Однако для получения рекомендаций на основе погоды требуется подключение к сети.
                </div>
              </details>

              <details className="group bg-white/60 dark:bg-gray-800/40 backdrop-blur-xl rounded-xl sm:rounded-2xl border border-gray-200 dark:border-gray-700 overflow-hidden transition-all duration-300 hover:shadow-lg">
                <summary className="flex items-center justify-between p-4 sm:p-6 cursor-pointer font-semibold text-sm sm:text-base text-gray-900 dark:text-white">
                  Как добавить вещи в гардероб?
                  <ChevronDown className="w-4 h-4 sm:w-5 sm:h-5 transition-transform group-open:rotate-180 flex-shrink-0 ml-2" />
                </summary>
                <div className="px-4 sm:px-6 pb-4 sm:pb-6 text-sm sm:text-base text-gray-600 dark:text-gray-400">
                  Откройте раздел «Гардероб» и добавьте ваши вещи вручную. Укажите категорию, цвет, бренд и другие параметры для каждой вещи.
                </div>
              </details>

              <details className="group bg-white/60 dark:bg-gray-800/40 backdrop-blur-xl rounded-xl sm:rounded-2xl border border-gray-200 dark:border-gray-700 overflow-hidden transition-all duration-300 hover:shadow-lg">
                <summary className="flex items-center justify-between p-4 sm:p-6 cursor-pointer font-semibold text-sm sm:text-base text-gray-900 dark:text-white">
                  Как связаться с поддержкой?
                  <ChevronDown className="w-4 h-4 sm:w-5 sm:h-5 transition-transform group-open:rotate-180 flex-shrink-0 ml-2" />
                </summary>
                <div className="px-4 sm:px-6 pb-4 sm:pb-6 text-sm sm:text-base text-gray-600 dark:text-gray-400">
                  Напишите нам на <a href="mailto:outfitstyle.official.app@gmail.com" className="text-primary-600 dark:text-primary-400 hover:underline">outfitstyle.official.app@gmail.com</a>. Мы отвечаем в течение 24 часов.
                </div>
              </details>
            </div>
          </div>
        </section>

        {/* Call to Action Banner */}
        <section id="download" className="py-24 px-4 sm:px-6 lg:px-8 relative z-20">
          <div className="max-w-5xl mx-auto text-center">
            <div className="relative rounded-3xl overflow-hidden shadow-2xl">
              <div className="absolute inset-0 bg-gradient-to-r from-primary-600 to-accent-600"></div>
              <div className="absolute inset-0 bg-[url('https://images.unsplash.com/photo-1483985988355-763728e1935b?auto=format&fit=crop&q=80&w=2000')] opacity-20 mix-blend-overlay bg-cover bg-center"></div>

              <div className="relative z-10 p-12 md:p-20 text-white">
                <h2 className="text-4xl md:text-5xl font-bold mb-6">Готовы изменить свой стиль?</h2>
                <p className="text-xl text-white/90 mb-10 max-w-2xl mx-auto">
                  Присоединяйтесь к тысячам пользователей, которые уже доверили свой утренний образ технологиям. Скачайте приложение прямо сейчас.
                </p>
                <div className="flex flex-col sm:flex-row justify-center gap-4">
                  <a href="#" className="px-8 py-4 bg-white text-gray-900 font-bold rounded-full hover:scale-105 transition-transform shadow-xl flex items-center justify-center gap-2">
                    <svg className="w-6 h-6" viewBox="0 0 24 24" fill="currentColor">
                      <path d="M16.365 21.493c-1.353 1.054-2.827.818-4.07-.06-.91-.643-1.897-.61-2.808.06-1.282.946-2.618 1.07-4.116-.06C2.26 18.066 1.103 13.916 2.38 9.531c.642-2.193 1.947-3.765 3.963-4.322 1.547-.424 2.97.042 3.92.83.67.556 1.48.513 2.158.006 1.066-.79 2.47-1.123 4.145-.583 1.706.55 2.85 1.724 3.442 3.45-3.085 1.41-3.567 4.786-1.162 6.51-1.026 2.473-2.193 4.414-2.481 6.071zm-6.22-16.79c-.066-2.492 1.83-4.706 4.227-4.703.11 2.502-1.841 4.793-4.227 4.703z" />
                    </svg>
                    App Store
                  </a>
                  <a href="#" className="px-8 py-4 bg-gray-900 text-white font-bold rounded-full hover:scale-105 transition-transform shadow-xl flex items-center justify-center gap-2 border border-gray-700">
                    <svg className="w-5 h-5" viewBox="0 0 24 24" fill="currentColor">
                      <path d="M3.13 2.222l12.446 12.446-2.923 2.923L3.13 2.222zm1.61-1.056L18.4 14.82l2.365-2.365L4.74 1.166zm13.684 15.688L5.95 24l-1.02-1.02 12.474-12.474 1.02 1.02zm.98-.98l2.91-2.91L5.95 0 3.04 2.91l16.365 16.365z" />
                    </svg>
                    Google Play
                  </a>
                </div>
              </div>
            </div>
          </div>
        </section>

      </main>

      {/* Footer */}
      <footer className="relative z-20 border-t border-gray-200/50 dark:border-gray-800/50 bg-white/50 dark:bg-[#090a0f]/50 backdrop-blur-lg pt-16 pb-8">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid md:grid-cols-4 gap-12 mb-12">
            <div className="col-span-2">
              <div className="flex items-center gap-2 text-gray-900 dark:text-white font-bold text-xl mb-4">
                <img src={logo} alt="OutfitStyle" className="w-8 h-8 rounded-lg object-cover" />
                OutfitStyle
              </div>
              <p className="text-gray-500 dark:text-gray-400 max-w-sm">
                Твой персональный стилист в кармане. Умные рекомендации на основе погоды, твоих предпочтений и трендов.
              </p>
            </div>
            <div>
              <h4 className="font-semibold mb-4 text-gray-900 dark:text-white">Продукт</h4>
              <ul className="space-y-3 text-sm text-gray-500 dark:text-gray-400">
                <li><a href="#features" className="hover:text-primary-500 transition-colors">Возможности</a></li>
                <li><a href="#download" className="hover:text-primary-500 transition-colors">Скачать для iOS</a></li>
                <li><a href="#download" className="hover:text-primary-500 transition-colors">Скачать для Android</a></li>
              </ul>
            </div>
            <div>
              <h4 className="font-semibold mb-4 text-gray-900 dark:text-white">Поддержка</h4>
              <ul className="space-y-3 text-sm text-gray-500 dark:text-gray-400">
                <li><a href="#faq" className="hover:text-primary-500 transition-colors">FAQ</a></li>
                <li><a href="mailto:outfitstyle.official.app@gmail.com" className="hover:text-primary-500 transition-colors">outfitstyle.official.app@gmail.com</a></li>
              </ul>
            </div>
          </div>
          <div className="border-t border-gray-200 dark:border-gray-800 pt-8 flex flex-col md:flex-row justify-between items-center gap-4 text-sm text-gray-500">
            <p>&copy; {new Date().getFullYear()} OutfitStyle. Все права защищены.</p>
            <div className="flex gap-4">
              <a href="/privacy" className="hover:text-gray-900 dark:hover:text-white transition-colors">Политика конфиденциальности</a>
              <a href="/terms" className="hover:text-gray-900 dark:hover:text-white transition-colors">Условия использования</a>
            </div>
          </div>
        </div>
      </footer>
    </div>
  );
}
