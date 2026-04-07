import os
import socket
import time

from flask import Flask, jsonify

START_TIME = time.time()

def get_env(name: str, default: str) -> str:
    return os.getenv(name, default)


def create_app() -> Flask:
    app = Flask(__name__)

    app.config["APP_ENV"] = get_env("APP_ENV", "default")
    app.config["APP_MESSAGE"] = get_env("APP_MESSAGE", "Hello from Platform Engineering Project 4 🚀")
    app.config["READINESS_DELAY_SECONDS"] = int(get_env("READINESS_DELAY_SECONDS", "0"))
    app.config["REQUIRE_MESSAGE"] = get_env("REQUIRE_MESSAGE", "false").lower() == "true"

    @app.route("/")
    def hello():
        return jsonify(
            message=app.config["APP_MESSAGE"],
            environment=app.config["APP_ENV"],
            hostname=socket.gethostname(),
        )

    @app.route("/configz")
    def configz():
        return jsonify(
            environment=app.config["APP_ENV"],
            readinessDelaySeconds=app.config["READINESS_DELAY_SECONDS"],
            requireMessage=app.config["REQUIRE_MESSAGE"],
        )

    @app.route("/livez")
    def livez():
        return jsonify(status="alive"), 200

    @app.route("/readyz")
    def readyz():
        uptime_seconds = int(time.time() - START_TIME)

        if uptime_seconds < app.config["READINESS_DELAY_SECONDS"]:
            return jsonify(
                status="not_ready",
                reason="startup_delay",
                uptimeSeconds=uptime_seconds,
            ), 503

        if app.config["REQUIRE_MESSAGE"] and not app.config["APP_MESSAGE"].strip():
            return jsonify(
                status="not_ready",
                reason="missing_app_message",
            ), 503

        return jsonify(
            status="ready",
            uptimeSeconds=uptime_seconds,
        ), 200

    return app

app = create_app()

if __name__ == "__main__":
    port = int(get_env("PORT", "5000"))
    app.run(host="0.0.0.0", port=port)