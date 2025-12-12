"""
Скрипт для проверки производительности retrieval-запросов к БД.
"""
import psycopg2
import time
import argparse
from typing import Dict, Any, List
import statistics


def test_retrieval_performance(
    connection_params: Dict[str, Any], 
    test_queries: List[str],
    iterations: int = 10
) -> Dict[str, Any]:
    """
    Проверить производительность retrieval-запросов.
    """
    results = {
        'query_times': [],
        'avg_time': 0,
        'min_time': 0,
        'max_time': 0,
        'p95_time': 0,
        'p99_time': 0,
        'iterations': iterations,
    }
    
    with psycopg2.connect(**connection_params) as conn:
        with conn.cursor() as cur:
            query_times = []
            
            for i in range(iterations):
                for query in test_queries:
                    start_time = time.time()
                    
                    try:
                        cur.execute(query)
                        rows = cur.fetchall()
                        query_time = (time.time() - start_time) * 1000  # в миллисекундах
                        query_times.append(query_time)
                        
                        print(f"Итерация {i+1}, запрос выполнено за {query_time:.2f}мс, "
                              f"найдено {len(rows)} записей")
                    except Exception as e:
                        print(f"Ошибка выполнения запроса: {e}")
                        continue
    
    if query_times:
        results['query_times'] = query_times
        results['avg_time'] = statistics.mean(query_times)
        results['min_time'] = min(query_times)
        results['max_time'] = max(query_times)
        results['p95_time'] = statistics.quantiles(query_times, n=20)[-1]  # 95-й перцентиль
        results['p99_time'] = statistics.quantiles(query_times, n=100)[-1]  # 99-й перцентиль
    
    return results


def print_performance_report(results: Dict[str, Any]):
    """
    Вывести отчет о производительности.
    """
    print("\n" + "="*60)
    print("ОТЧЕТ О ПРОИЗВОДИТЕЛЬНОСТИ RETRIEVAL-ЗАПРОСОВ")
    print("="*60)
    
    print(f"Количество итераций: {results['iterations']}")
    print(f"Среднее время: {results['avg_time']:.2f}мс")
    print(f"Минимальное время: {results['min_time']:.2f}мс")
    print(f"Максимальное время: {results['max_time']:.2f}мс")
    print(f"95-й перцентиль: {results['p95_time']:.2f}мс")
    print(f"99-й перцентиль: {results['p99_time']:.2f}мс")
    
    print("\nРекомендации:")
    if results['p95_time'] > 100:  # > 100мс для 95-го перцентиля
        print("  - Рассмотрите оптимизацию запросов или добавление индексов")
    else:
        print("  - Производительность в норме")
    
    if results['max_time'] > 500:  # > 500мс для максимального времени
        print("  - Проверьте наличие медленных запросов и добавьте необходимые индексы")
    
    print("="*60)


def main():
    parser = argparse.ArgumentParser(description='Test retrieval query performance')
    parser.add_argument('--host', default='localhost', help='Database host')
    parser.add_argument('--port', type=int, default=5432, help='Database port')
    parser.add_argument('--dbname', default='outfitstyle', help='Database name')
    parser.add_argument('--user', default='Admin', help='Database user')
    parser.add_argument('--password', default='password', help='Database password')
    parser.add_argument('--iterations', type=int, default=10, help='Number of test iterations')
    parser.add_argument('--category', default='upper', help='Category for test query')
    parser.add_argument('--temperature', type=int, default=15, help='Temperature for test query')
    
    args = parser.parse_args()
    
    connection_params = {
        'host': args.host,
        'port': args.port,
        'dbname': args.dbname,
        'user': args.user,
        'password': args.password
    }
    
    # Тестовые запросы для проверки производительности retrieval
    test_queries = [
        # Основной retrieval запрос (как в реальной системе)
        f"""
        SELECT id, name, category, subcategory, gender, style, usage, season, base_colour,
               formality_level, warmth_level, min_temp, max_temp, materials, fit, pattern,
               icon_emoji, source, is_owned, created_at
        FROM clothing_items
        WHERE category = '{args.category}'
          AND warmth_level >= 3
          AND {args.temperature} BETWEEN min_temp AND max_temp
        ORDER BY warmth_level DESC, formality_level ASC, id ASC
        LIMIT 30;
        """,
        
        # Запрос по нескольким подкатегориям (как при планировании)
        f"""
        SELECT id, name, category, subcategory, gender, style, usage, season, base_colour,
               formality_level, warmth_level, min_temp, max_temp, materials, fit, pattern,
               icon_emoji, source, is_owned, created_at
        FROM clothing_items
        WHERE category = '{args.category}'
          AND subcategory IN ('tshirt', 'shirt', 'hoodie')
          AND warmth_level >= 2
          AND {args.temperature} BETWEEN min_temp AND max_temp
        ORDER BY warmth_level DESC, formality_level ASC, id ASC
        LIMIT 25;
        """,
        
        # Запрос пользовательских вещей (гардероб)
        f"""
        SELECT ci.id, ci.name, ci.category, ci.subcategory, ci.gender, ci.style, ci.usage, ci.season, ci.base_colour,
               ci.formality_level, ci.warmth_level, ci.min_temp, ci.max_temp, ci.materials, ci.fit, ci.pattern,
               ci.icon_emoji, ci.source, ci.is_owned, ci.created_at
        FROM clothing_items ci
        JOIN wardrobe_items wi ON ci.id = wi.clothing_item_id
        WHERE wi.user_id = 1
          AND ci.category = '{args.category}'
          AND {args.temperature} BETWEEN ci.min_temp AND ci.max_temp
        ORDER BY ci.warmth_level DESC, ci.formality_level ASC, ci.id ASC
        LIMIT 20;
        """
    ]
    
    print(f"Тестирование производительности retrieval-запросов...")
    print(f"Категория: {args.category}, Температура: {args.temperature}°C")
    
    try:
        results = test_retrieval_performance(connection_params, test_queries, args.iterations)
        print_performance_report(results)
    except psycopg2.Error as e:
        print(f"Ошибка подключения к БД: {e}")
    except Exception as e:
        print(f"Ошибка: {e}")


if __name__ == "__main__":
    main()