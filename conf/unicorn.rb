listen "localhost:4999"
worker_processes 4
pid "/tmp/unicorn-beeta.pid"
stderr_path "/tmp/unicorn-beeta.log"
stdout_path "/tmp/unicorn-beeta.log"
preload_app false
