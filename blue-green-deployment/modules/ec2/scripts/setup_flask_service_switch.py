import os
import sys

app_name = sys.argv[1] if len(sys.argv) > 1 else "default"
service_name = f"flask-app-{app_name}"
service_file = f"/etc/systemd/system/{service_name}.service"

# For switch pipeline: use the latest app file (app_2.py, not app_app2.py)
if app_name.startswith("app") and len(app_name) > 3:
    app_number = app_name[3:]  # Extract number from app2 -> 2
    app_script = f"/home/ec2-user/app_{app_number}.py"  # app2 -> app_2.py (latest version)
    old_app_script = f"/home/ec2-user/app_{app_name}.py"  # Keep old file for rollback
else:
    app_script = f"/home/ec2-user/app_{app_name}.py"
    old_app_script = None

print(f"Setting up service for app_name: {app_name}")
print(f"Using LATEST app script: {app_script}")
print(f"Preserving old app script for rollback: {old_app_script}")

# Kill any process using port 80 (suppress errors)
os.system("sudo fuser -k 80/tcp 2>/dev/null || true")

# Stop the old service
print(f"Stopping old service {service_name}...")
os.system(f"sudo systemctl stop {service_name} 2>/dev/null || true")
os.system(f"sudo systemctl disable {service_name} 2>/dev/null || true")

# Create systemd service file content pointing to latest app
service_content = f"""[Unit]
Description=Flask App for {app_name} (Latest Version)
After=network.target

[Service]
User=root
WorkingDirectory=/home/ec2-user
ExecStart=/usr/bin/python3 {app_script}
Restart=always

[Install]
WantedBy=multi-user.target
"""

# Write service file
with open(service_file, "w") as f:
    f.write(service_content)

print(f"Created service file pointing to latest app: {app_script}")

# Start service with latest app
os.system("sudo systemctl daemon-reload")
os.system(f"sudo systemctl enable {service_name}")
os.system(f"sudo systemctl start {service_name}")

print(f"Flask service for {app_name} has been set up with LATEST version and started.")
print(f"Previous version preserved for rollback capability.")

# Quick status check (non-blocking)
os.system(f"sudo systemctl is-active {service_name} --quiet && echo 'Service is running with latest version' || echo 'Service may still be starting'")