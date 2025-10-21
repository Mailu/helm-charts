"""
This script checks if environments variables from Mailu master branch are all considered in the Helm Chart.
"""
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import os
from pprint import pprint
import re

import requests
import yaml
from tabulate import tabulate


MAPPING = {
    # Specific to the admin UI
    "DOCKER_SOCKET": (False, "Not necessary"),
    "BABEL_DEFAULT_LOCALE": ("", ""),
    "BABEL_DEFAULT_TIMEZONE": ("", ""),
    "BOOTSTRAP_SERVE_LOCAL": ("", ""),
    "RATELIMIT_STORAGE_URL": (False, "Managed by Helm chart"),
    "DEBUG": ("", ""),
    "DEBUG_PROFILER": ("", ""),
    "DEBUG_TB_INTERCEPT_REDIRECTS": ("", ""),
    "DEBUG_ASSETS": ("", ""),
    "DOMAIN_REGISTRATION": ("", ""),
    "TEMPLATES_AUTO_RELOAD": ("", ""),
    "MEMORY_SESSIONS": ("", ""),
    "FETCHMAIL_ENABLED": ("fetchmail.enabled", ""),
    # Database settings
    "DB_FLAVOR": (False, "Managed by Helm chart"),
    "DB_USER": (False, "Managed by Helm chart"),
    "DB_PW": (False, "Managed by Helm chart"),
    "DB_HOST": (False, "Managed by Helm chart"),
    "DB_NAME": (False, "Managed by Helm chart"),
    "DB_APPENDIX": (False, "Managed by Helm chart"),
    "SQLITE_DATABASE_FILE": ("", ""),
    "SQLALCHEMY_DATABASE_URI": ("", ""),
    "SQLALCHEMY_TRACK_MODIFICATIONS": ("", ""),
    # Statistics management
    "INSTANCE_ID_PATH": ("", ""),
    "STATS_ENDPOINT": ("", ""),
    # Common configuration variables
    "SECRET_KEY": ("", ""),
    "DOMAIN": ("domain", ""),
    "HOSTNAMES": ("hostnames", ""),
    "POSTMASTER": ("postmaster", ""),
    "WILDCARD_SENDERS": ("", ""),
    "TLS_FLAVOR": ("ingress.tlsFlavorOverride", ""),
    "INBOUND_TLS_ENFORCE": ("", ""),
    "DEFER_ON_TLS_ERROR": ("", ""),
    "AUTH_RATELIMIT_IP": ("limits.authRatelimit.ip", ""),
    "AUTH_RATELIMIT_IP_V4_MASK": ("limits.authRatelimit.ipv4Mask", ""),
    "AUTH_RATELIMIT_IP_V6_MASK": ("limits.authRatelimit.ipv6Mask", ""),
    "AUTH_RATELIMIT_USER": ("limits.authRatelimit.user", ""),
    "AUTH_RATELIMIT_EXEMPTION": ("limits.authRatelimit.exemption", ""),
    "AUTH_RATELIMIT_EXEMPTION_LENGTH": ("limits.authRatelimit.exemptionLength", ""),
    "DISABLE_STATISTICS": ("", ""),
    # Mail settings
    "DMARC_RUA": ("", ""),
    "DMARC_RUF": ("", ""),
    "WELCOME": ("", ""),
    "WELCOME_SUBJECT": ("", ""),
    "WELCOME_BODY": ("", ""),
    "DKIM_SELECTOR": ("", ""),
    "DKIM_PATH": ("", ""),
    "DEFAULT_QUOTA": ("", ""),
    "MESSAGE_RATELIMIT": ("limits.messageRatelimit.value", ""),
    "MESSAGE_RATELIMIT_EXEMPTION": ("limits.messageRatelimit.exemption", ""),
    "RECIPIENT_DELIMITER": ("", ""),
    # Web settings
    "SITENAME": ("", ""),
    "WEBSITE": ("", ""),
    "ADMIN": ("", ""),
    "WEB_ADMIN": ("", ""),
    "WEB_WEBMAIL": ("webmail.uri", ""),
    "WEBMAIL": ("webmail.type", ""),
    "RECAPTCHA_PUBLIC_KEY": ("", ""),
    "RECAPTCHA_PRIVATE_KEY": ("", ""),
    "LOGO_URL": ("", ""),
    "LOGO_BACKGROUND": ("", ""),
    # Advanced settings
    "LOG_LEVEL": ("logLevel", ""),
    "SESSION_KEY_BITS": ("", ""),
    "SESSION_TIMEOUT": ("sessionTimeout", ""),
    "PERMANENT_SESSION_LIFETIME": ("permanentSessionLifetime", ""),
    "SESSION_COOKIE_SECURE": ("sessionCookieSecure", ""),
    "CREDENTIAL_ROUNDS": ("credentialRounds", ""),
    "TLS_PERMISSIVE": ("", ""),
    "TZ": ("timezone", ""),
    "DEFAULT_SPAM_THRESHOLD": ("", ""),
    "PROXY_AUTH_WHITELIST": ("", ""),
    "PROXY_AUTH_HEADER": ("", ""),
    "PROXY_AUTH_CREATE": ("", ""),
    # Host settings
    "HOST_IMAP": (False, "Managed by Helm chart"),
    "HOST_LMTP": (False, "Managed by Helm chart"),
    "HOST_POP3": (False, "Managed by Helm chart"),
    "HOST_SMTP": (False, "Managed by Helm chart"),
    "HOST_AUTHSMTP": (False, "Managed by Helm chart"),
    "HOST_ADMIN": (False, "Managed by Helm chart"),
    "HOST_WEBMAIL": (False, "Managed by Helm chart"),
    "HOST_WEBDAV": (False, "Managed by Helm chart"),
    "HOST_REDIS": (False, "Managed by Helm chart"),
    "HOST_FRONT": (False, "Managed by Helm chart"),
    "SUBNET": ("subnet", ""),
    "SUBNET6": (False, "Not supported yet by Helm chart"),
}


class EnvVarChecker:
    """Check if all environment variables are considered in the Helm Chart"""

    def __init__(self, mapping) -> None:
        self.base_path = os.path.dirname(os.path.abspath(__file__))
        self.mailu_config_url = "https://raw.githubusercontent.com/Mailu/Mailu/master/core/admin/mailu/configuration.py"
        self.mailu_config = None
        self.mapping = mapping
        self.helm_values = {}
        self.env_vars = {}

    def get_mailu_config(self):
        """Get the Mailu configuration file"""
        # request https://github.com/Mailu/Mailu/raw/master/core/admin/mailu/configuration.py
        req = requests.get(
            self.mailu_config_url,
            timeout=5,
        )
        req.raise_for_status()

        self.mailu_config = req.text.splitlines()

        return True

    def get_env_vars_from_mailu(self):
        """Get the environment variables from the Mailu configuration file"""

        if not self.mailu_config:
            self.get_mailu_config()

        found = False
        self.env_vars = {}
        group = ""

        for line in self.mailu_config:
            if "DEFAULT_CONFIG" in line:
                found = True
                continue
            if found:
                # End of DEFAULT_CONFIG
                if line.startswith("}"):
                    break
                # Group
                if line.strip().startswith("#"):
                    group = line.strip()[1:].strip()
                    continue

                name = line.split(": ")[0].strip()
                if name.startswith("'"):
                    name = name[1:-1]

                default_value = line.split(": ")[1].strip()
                if default_value.startswith("'"):
                    default_value = default_value[1:-1]

                # extract name using regex
                name_reg = re.findall(
                    r"'([\w_]+)'\s*:\s*('?)((?:.*[^,])|(?:[^,]*.))\2\s*,?$",
                    line.strip(),
                )

                if len(name_reg) != 1:
                    print(f"ERROR: Cannot extract name/value from line: {line}")
                    continue

                name = name_reg[0][0]
                default_value = name_reg[0][2]
                quoted = name_reg[0][1] == "'" or name_reg[0][1] == '"'

                self.env_vars[name] = {
                    "group": group,
                    "name": name,
                    "default_value": default_value,
                    "quoted": quoted,
                    "path": "",
                    "helm_default_value": "",
                    "comment": "",
                }

    def import_helm_values(self):
        """Import the Helm values.yaml file"""
        values_file = os.path.join(self.base_path, "..", "charts", "mailu", "values.yaml")
        with open(values_file, "r", encoding="utf-8") as file:
            self.helm_values = yaml.safe_load(file)

    def get_value(self, path):
        """Get a value from a nested dict"""

        if len(self.helm_values) == 0:
            self.import_helm_values()

        value = self.helm_values
        for key in path.split("."):
            if key not in value:
                print(f"ERROR: Missing {path}")
                return None
            value = value[key]

        return value

    def check_env_vars(self):
        """Check if all environment variables are considered in the Helm Chart"""
        if len(self.env_vars) == 0:
            self.get_env_vars_from_mailu()

        for (name, env_var) in self.env_vars.items():
            default_value = env_var["default_value"]

            if name not in self.mapping:
                env_var["status"] = "missing_mapping"
                continue

            env_var["comment"] = self.mapping[name][1]

            if self.mapping[name][0] is False:
                env_var["status"] = "skipped"
                continue

            if self.mapping[name][0] == "":
                env_var["status"] = "empty_mapping"
                continue

            helm_default_value = self.get_value(self.mapping[name][0])

            if helm_default_value is None:
                env_var["status"] = "missing_helm_value"
                continue

            env_var["path"] = self.mapping[name][0]
            env_var["helm_default_value"] = helm_default_value

            if helm_default_value != default_value:
                env_var["status"] = "default_value_mismatch"
                continue

            self.env_vars[name]["status"] = "ok"

    def get_grouped_by(self, key):
        """Get a dict of env vars grouped by a key"""
        if len(self.env_vars) == 0:
            self.check_env_vars()

        by_key = {}
        for (name, env_var) in self.env_vars.items():
            if env_var[key] not in by_key:
                by_key[env_var[key]] = {}
            by_key[env_var[key]][name] = env_var

        return by_key

    def print_status(self):
        """Print the status of the environment variables"""
        tabs = []
        headers = [
            "Mailu env var",
            "Helm config path",
            "Status",
            "Comment",
            "Default value",
            "Helm default value",
        ]
        for (status, env_vars) in self.get_grouped_by("status").items():
            print(f"### {status} ({len(env_vars)}) ###")
            for (name, env_var) in env_vars.items():
                tabs.append(
                    [
                        name,
                        env_var["path"],
                        status,
                        env_var["comment"],
                        env_var["default_value"],
                        env_var["helm_default_value"],
                    ]
                )

        print(tabulate(tabs, headers=headers, tablefmt="github"))

    def print_configmap(self):
        """Print the configmap for the environment variables"""

        for (name, env_var) in self.env_vars.items():
            if env_var["status"] in ["ok", "default_value_mismatch"]:
                quoted_str = "| quote " if env_var["quoted"] else ""
                print(f"{name}: {{{{ .Values.{env_var['path']} {quoted_str} }}}}")

checker = EnvVarChecker(MAPPING)
checker.check_env_vars()
if "HOSTNAMES" in checker.env_vars:
    pprint(checker.env_vars["HOSTNAMES"])
checker.print_status()

checker.print_configmap()

# for env_var in env_vars:
#     print(f"env_var: {env_var['name']} {env_var['default_value']} {env_var['quoted']}")
