import asyncio
from aiogram import Bot, Dispatcher
from aiogram.types import Message
import aio_pika
import os

API_TOKEN = os.getenv('TELEGRAM_API_TOKEN')
CHAT_ID = os.getenv('TELEGRAM_CHAT_ID')

bot = Bot(token=API_TOKEN)
dp = Dispatcher()

async def start_bot():
    await bot.send_message(chat_id=CHAT_ID, text="Telegram bot started.")
    await consume_messages()

async def consume_messages():
    connection = await aio_pika.connect_robust("amqp://guest:guest@rabbitmq/")
    channel = await connection.channel()
    queue = await channel.declare_queue("trades_queue", durable=True)

    async with queue.iterator() as queue_iter:
        async for message in queue_iter:
            async with message.process():
                await bot.send_message(chat_id=CHAT_ID, text=message.body.decode())

if __name__ == '__main__':
    asyncio.run(start_bot())
