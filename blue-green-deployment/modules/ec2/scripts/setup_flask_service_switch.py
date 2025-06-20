import os
import sys

# Parse arguments
app_name = sys.argv[1] if len(sys.argv) > 1 else "default"
mode = sys.argv[2] if len(sys.argv) > 2 else "switch"  # default to switch

service_name = f"flask-app-{app_name}"
service_file = f"/etc/systemd/system/{service_name}.service"

# Determine script based on mode
if app_name.startswith("app") and len(app_name) > 3:
    app_number = app_name[3:]  # e.g., from app2 → "2"

    if mode == "rollback":
        app_script = f"/home/ec2-user/app_app_{app_number}.py"  # Old/stable
        print(f"🛑 Rollback mode triggered")
    else:
        app_script = f"/home/ec2-user/app_{app_number}.py"       # Latest/new
        print(f"🚀 Switch mode triggered (default)")
else:
    app_script = f"/home/ec2-user/app_{app_name}.py"

print(f"App name: {app_name}")
print(f"Mode: {mode}")
print(f"Selected app script: {app_script}")

# Kill any existing process on port 80
os.system("sudo fuser -k 80/tcp 2>/dev/null || true")

# Stop and disable the existing service
print(f"🔻 Stopping old service: {service_name}")
os.system(f"sudo systemctl stop {service_name} 2>/dev/null || true")
os.system(f"sudo systemctl disable {service_name} 2>/dev/null || true")

# Create new service content
service_content = f"""[Unit]
Description=Flask App for {app_name} ({mode.capitalize()} Mode)
After=network.target

[Service]
User=root
WorkingDirectory=/home/ec2-user
ExecStart=/usr/bin/python3 {app_script}
Restart=always

[Install]
WantedBy=multi-user.target
"""

# Write the systemd service file
with open(service_file, "w") as f:
    f.write(service_content)

print(f"✅ Created systemd service file: {service_file}")

# Reload and start new service
os.system("sudo systemctl daemon-reload")
os.system(f"sudo systemctl enable {service_name}")
os.system(f"sudo systemctl start {service_name}")

# Final status
print(f"✅ Flask service '{service_name}' has been started with script: {app_script}")
os.system(f"sudo systemctl is-active {service_name} --quiet && echo 'Service is running ✅' || echo 'Service may still be starting ⏳'")
