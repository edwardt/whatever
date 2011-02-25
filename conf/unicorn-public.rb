listen "0.0.0.0:4999"
worker_processes 4
pid "/var/run/unicorn/beeta.pid"
stderr_path "/var/log/unicorn/beeta.log"
stdout_path "/var/log/unicorn/beeta.log"
preload_app true
