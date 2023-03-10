{{ $user := .Values.global.postgresql.auth.username }}

GRANT USAGE, CREATE ON SCHEMA public TO {{ $user }};
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO {{ $user }};
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO {{ $user }};
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO {{ $user }};
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE ON SEQUENCES TO  {{ $user }};
CREATE database {{ $user }};
