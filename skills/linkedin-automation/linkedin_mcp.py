#!/usr/bin/env python3
"""
LinkedIn MCP Server
MCP сервер для мониторинга LinkedIn постов, комментариев и аналитики
"""

import json
import sys
import subprocess
from pathlib import Path
from typing import Dict, List, Optional, Any
import os

# Путь к LinkedIn скрипту
LINKEDIN_SCRIPT = Path(os.getenv(
    "LINKEDIN_SCRIPT",
    "/root/.openclaw/workspace/skills/linkedin-automation/scripts/linkedin.py"
))

# Отладочный режим
DEBUG = os.getenv("LINKEDIN_DEBUG", "0") == "1"


def log_debug(message: str):
    """Логирование отладочных сообщений"""
    if DEBUG:
        print(f"[DEBUG] {message}", file=sys.stderr)


def call_linkedin(command: str, args: List[str] = None) -> Dict[str, Any]:
    """
    Выполняет команду LinkedIn CLI и возвращает результат
    
    Args:
        command: Команда для выполнения (feed, analytics, etc.)
        args: Дополнительные аргументы
    
    Returns:
        Словарь с результатом или ошибкой
    """
    try:
        cmd = [str(LINKEDIN_SCRIPT), command]
        if args:
            cmd.extend(args)
        
        log_debug(f"Executing: {' '.join(cmd)}")
        
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=60,
            cwd=LINKEDIN_SCRIPT.parent
        )
        
        if result.returncode != 0:
            error_msg = result.stderr.strip() or "Unknown error"
            log_debug(f"Command failed: {error_msg}")
            return {
                "success": False,
                "error": error_msg,
                "exit_code": result.returncode
            }
        
        # Парсим JSON вывод
        output = result.stdout.strip()
        if output:
            try:
                data = json.loads(output)
                return {
                    "success": True,
                    "data": data
                }
            except json.JSONDecodeError as e:
                log_debug(f"JSON parse error: {e}")
                return {
                    "success": False,
                    "error": f"Invalid JSON output: {str(e)}",
                    "raw_output": output
                }
        
        return {
            "success": True,
            "data": None
        }
        
    except subprocess.TimeoutExpired:
        return {
            "success": False,
            "error": "Command timed out after 60 seconds"
        }
    except Exception as e:
        log_debug(f"Exception: {e}")
        return {
            "success": False,
            "error": str(e)
        }


def read_feed(params: Dict[str, Any]) -> Dict[str, Any]:
    """Читать LinkedIn feed"""
    count = params.get("count", 5)
    log_debug(f"Reading feed: {count} posts")
    
    return call_linkedin("feed", ["--count", str(count)])


def check_session(params: Dict[str, Any]) -> Dict[str, Any]:
    """Проверить валидность LinkedIn сессии"""
    log_debug("Checking session")
    
    return call_linkedin("check-session")


def analytics(params: Dict[str, Any]) -> Dict[str, Any]:
    """Получить аналитику для последних постов"""
    count = params.get("count", 10)
    log_debug(f"Getting analytics: {count} posts")
    
    return call_linkedin("analytics", ["--count", str(count)])


def profile_stats(params: Dict[str, Any]) -> Dict[str, Any]:
    """Получить статистику профиля"""
    log_debug("Getting profile stats")
    
    return call_linkedin("profile-stats")


def scan_likes(params: Dict[str, Any]) -> Dict[str, Any]:
    """Сканировать новые лайки"""
    count = params.get("count", 15)
    log_debug(f"Scanning likes: {count} items")
    
    return call_linkedin("scan-likes", ["--count", str(count)])


def activity(params: Dict[str, Any]) -> Dict[str, Any]:
    """Получить активность профиля"""
    profile_url = params.get("profileUrl")
    count = params.get("count", 5)
    
    if not profile_url:
        return {
            "success": False,
            "error": "Missing required parameter: profileUrl"
        }
    
    log_debug(f"Getting activity: {profile_url} ({count} items)")
    
    return call_linkedin("activity", [
        "--profile-url", profile_url,
        "--count", str(count)
    ])


# Mapped функции для инструментов
TOOLS = {
    "read_feed": read_feed,
    "check_session": check_session,
    "analytics": analytics,
    "profile_stats": profile_stats,
    "scan_likes": scan_likes,
    "activity": activity,
}


def handle_tool_call(tool_name: str, params: Dict[str, Any]) -> Dict[str, Any]:
    """
    Обрабатывает вызов инструмента MCP
    
    Args:
        tool_name: Имя инструмента
        params: Параметры инструмента
    
    Returns:
        Результат выполнения
    """
    if tool_name not in TOOLS:
        return {
            "success": False,
            "error": f"Unknown tool: {tool_name}"
        }
    
    return TOOLS[tool_name](params)


def main():
    """Main entry point for MCP server"""
    # Читаем stdin для MCP протокола
    try:
        # Простой MCP протокол - читаем JSON построчно
        for line in sys.stdin:
            if not line.strip():
                continue
            
            try:
                request = json.loads(line)
                
                # Обрабатываем tool/list
                if request.get("method") == "tools/list":
                    response = {
                        "jsonrpc": "2.0",
                        "id": request.get("id"),
                        "result": {
                            "tools": [
                                {
                                    "name": name,
                                    "description": func.__doc__,
                                }
                                for name, func in TOOLS.items()
                            ]
                        }
                    }
                    print(json.dumps(response))
                    sys.stdout.flush()
                
                # Обрабатываем tools/call
                elif request.get("method") == "tools/call":
                    params = request.get("params", {})
                    tool_name = params.get("name")
                    arguments = params.get("arguments", {})
                    
                    result = handle_tool_call(tool_name, arguments)
                    
                    response = {
                        "jsonrpc": "2.0",
                        "id": request.get("id"),
                        "result": {
                            "content": [
                                {
                                    "type": "text",
                                    "text": json.dumps(result, indent=2)
                                }
                            ]
                        }
                    }
                    print(json.dumps(response))
                    sys.stdout.flush()
                
                # Неизвестный метод
                else:
                    response = {
                        "jsonrpc": "2.0",
                        "id": request.get("id"),
                        "error": {
                            "code": -32601,
                            "message": "Method not found"
                        }
                    }
                    print(json.dumps(response))
                    sys.stdout.flush()
            
            except json.JSONDecodeError as e:
                log_debug(f"JSON decode error: {e}")
                continue
    
    except KeyboardInterrupt:
        pass
    except Exception as e:
        log_debug(f"Server error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
