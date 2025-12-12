"""
Скрипт для анализа плана запросов и оптимизации индексов в PostgreSQL.
"""
import psycopg2
import argparse
from typing import Dict, Any
import json


def analyze_query_plan(connection_params: Dict[str, Any], query: str, params: tuple = None) -> Dict[str, Any]:
    """Анализ плана выполнения запроса с помощью EXPLAIN ANALYZE."""
    with psycopg2.connect(**connection_params) as conn:
        with conn.cursor() as cur:
            # Подготовка EXPLAIN ANALYZE запроса
            explain_query = f"EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON) {query}"
            
            if params:
                cur.execute(explain_query, params)
            else:
                cur.execute(explain_query)
            
            result = cur.fetchone()[0]  # Результат в формате JSON
            
            return result


def suggest_indexes(query_plan: Dict[str, Any]) -> list:
    """Предложить индексы на основе плана запроса."""
    suggestions = []
    
    # Рекурсивная функция для поиска узлов плана
    def find_nodes(plan, node_type):
        nodes = []
        if plan.get('Node Type') == node_type:
            nodes.append(plan)
        
        # Поиск в дереве плана
        if 'Plans' in plan:
            for subplan in plan['Plans']:
                nodes.extend(find_nodes(subplan, node_type))
        elif 'Plan' in plan:
            nodes.extend(find_nodes(plan['Plan'], node_type))
        
        return nodes
    
    # Поиск Seq Scan (последовательных сканирований) - потенциальный кандидат для индекса
    seq_scans = find_nodes(query_plan['Query Plan'], 'Seq Scan')
    for scan in seq_scans:
        rel_name = scan.get('Relation Name', 'unknown')
        # Скорее всего, нужно индексировать поля из WHERE
        suggestions.append(f"Потенциально нужен индекс для таблицы {rel_name} для ускорения фильтрации")
    
    # Поиск Sort узлов - возможно, нужен индекс с ORDER BY
    sorts = find_nodes(query_plan['Query Plan'], 'Sort')
    for sort in sorts:
        sort_keys = sort.get('Sort Key', [])
        if sort_keys:
            # Предложить индекс с этими полями
            fields = [key.split()[0] for key in sort_keys]  # Убираем ASC/DESC
            suggestions.append(f"Рассмотрите индекс с полями {fields} для ускорения сортировки")
    
    # Поиск Hash Join - возможно, нужен индекс на полях соединения
    hash_joins = find_nodes(query_plan['Query Plan'], 'Hash Join')
    for join in hash_joins:
        join_conds = join.get('Hash Cond', [])
        suggestions.append(f"Рассмотрите индексы на полях соединения: {join_conds}")
    
    return suggestions


def check_current_indexes(connection_params: Dict[str, Any], table_name: str) -> list:
    """Проверить существующие индексы для таблицы."""
    with psycopg2.connect(**connection_params) as conn:
        with conn.cursor() as cur:
            query = """
                SELECT 
                    indexname,
                    indexdef
                FROM pg_indexes 
                WHERE tablename = %s
                ORDER BY indexname;
            """
            cur.execute(query, (table_name,))
            return cur.fetchall()


def main():
    parser = argparse.ArgumentParser(description='Analyze PostgreSQL query plans and suggest indexes')
    parser.add_argument('--host', default='localhost', help='Database host')
    parser.add_argument('--port', type=int, default=5432, help='Database port')
    parser.add_argument('--dbname', default='outfitstyle', help='Database name')
    parser.add_argument('--user', default='Admin', help='Database user')
    parser.add_argument('--password', default='password', help='Database password')
    parser.add_argument('--query', help='Query to analyze (EXPLAIN ANALYZE)')
    parser.add_argument('--table', help='Check existing indexes for this table')
    
    args = parser.parse_args()
    
    connection_params = {
        'host': args.host,
        'port': args.port,
        'dbname': args.dbname,
        'user': args.user,
        'password': args.password
    }
    
    try:
        if args.table:
            print(f"Проверка существующих индексов для таблицы {args.table}...")
            indexes = check_current_indexes(connection_params, args.table)
            if indexes:
                print("Существующие индексы:")
                for name, definition in indexes:
                    print(f"  {name}: {definition}")
            else:
                print("  Нет существующих индексов")
        
        if args.query:
            print("Анализ плана запроса...")
            plan = analyze_query_plan(connection_params, args.query)
            
            print("\nПлан запроса (сокращенно):")
            print(json.dumps(plan, indent=2)[:2000] + "..." if len(str(plan)) > 2000 else json.dumps(plan, indent=2))
            
            print("\nПредложения по индексам:")
            suggestions = suggest_indexes(plan)
            for suggestion in suggestions:
                print(f"  - {suggestion}")
        
    except psycopg2.Error as e:
        print(f"Ошибка работы с БД: {e}")
    except Exception as e:
        print(f"Ошибка: {e}")


if __name__ == "__main__":
    main()