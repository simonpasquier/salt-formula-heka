heka:
  server:
    enabled: true
    input:
      rabbitmq:
        engine: amqp
        host: ${_param:heka_router_input_host}
        user: ${_param:heka_router_input_user}
        password: ${_param:heka_router_input_password}
        vhost: ${_param:heka_router_input_vhost}
        port: 5672
        exchange: ${_param:heka_router_input_exchange}
        exchange_type: fanout
        decoder: ProtoBufDecoder
        splitter: HekaFramingSplitter
        prefetch_count: 80
      rsyslog_syslog:
        engine: logstreamer
        log_directory: /var/log
        file_match: '(?P<Service>daemon\.log|cron\.log|mail\.log|kern\.log|auth\.log|syslog|messages|debug)\.?(?P<Index>\d+)?(.gz)?'
        priority: '["^Index"]'
        differentiator: '[ "rsyslog-", "Service" ]'
        decoder: RsyslogDecoder
        oldest_duration: "168h"
    decoder:
      rsyslog:
        engine: rsyslog
        template: \%TIMESTAMP\% \%HOSTNAME\% \%syslogtag\%\%msg:::sp-if-no-1st-sp\%\%msg:::drop-last-lf\%\n
        hostname_keep: TRUE
        tz: Europe/Prague
        type: rsyslog
      ProtoBufDecoder:
        engine: protobuf
    output:
      elasticsearch01:
        engine: elasticsearch
        host: ${_param:heka_router_output_host}
        port: 9200
        encoder: es_json
        message_matcher: "Logger != 'hekad'"
        flush_count: 50
        flush_interval: 500
        enabled: true
      dashboard01:
        engine: dashboard
        ticker_interval: 30
        enabled: true
      rabbitmq:
        enabled: false
    encoder:
      es_json:
        engine: es-json
      es_payload:
        engine: es-payload

