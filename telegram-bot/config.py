# telegram_bot/config.py

from pydantic import BaseSettings

class Settings(BaseSettings):
    rabbitmq_host: str = 'rabbitmq'
    rabbitmq_port: int = 5672
    api_token: str
    chat_id: str

    class Config:
        env_file = '.env'

settings = Settings()
