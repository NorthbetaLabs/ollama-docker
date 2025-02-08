#!/bin/bash
DINGTALK_WEBHOOK="https://open.feishu.cn/open-apis/bot/v2/hook/4c69e5c4-1a23-43a8-9842-65a6fdb5f51b"
STATUS=$(docker exec -it ollama /bin/bash -c "ollama ps" | awk 'NR==2 {print $5}')

if [ "$STATUS" == "Stopping" ]; then
    curl --location --request POST 'https://open.feishu.cn/open-apis/bot/v2/hook/4c69e5c4-1a23-43a8-9842-65a6fdb5f51b' \--header 'Content-Type: application/json' \--data-raw '{"msg_type":"text","content":{"text":"Ollama 服务存在异常... \n 正在重启中"}}'
    docker-compose down
    docker-compose -f /root/ollama-docker/docker-compose-ollama-gpu-h100.yaml up -d
    docker exec -it ollama /bin/bash -c "ollama run deepseek-r1:671b" &
  # 发送恢复通知
    STATUS_AFTER_RESTART=$(docker exec -it ollama /bin/bash -c "ollama ps " |wc -l)
    if [ "$STATUS_AFTER_RESTART" != "Stopping" ]; then
        curl --location --request POST 'https://open.feishu.cn/open-apis/bot/v2/hook/4c69e5c4-1a23-43a8-9842-65a6fdb5f51b' \--header 'Content-Type: application/json' \--data-raw '{"msg_type":"text","content":{"text":"Ollama 服务已成功重启，正常运行"}}'
    else
        curl --location --request POST 'https://open.feishu.cn/open-apis/bot/v2/hook/4c69e5c4-1a23-43a8-9842-65a6fdb5f51b' \--header 'Content-Type: application/json' \--data-raw '{"msg_type":"text","content":{"text":"Ollama 服务重启失败，当前状态仍为Stopping。"}}'
    fi
else
    echo "Ollama 服务当前状态：$STATUS，无需操作。"
fi