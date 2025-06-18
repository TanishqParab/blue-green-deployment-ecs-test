import os
import sys
import time

# Get the app name from command line argument
app_name = sys.argv[1] if len(sys.argv) > 1 else "default"

service_file = f"/etc/systemd/system/flask-app-{app_name}.service"

# Determine the correct app file name
if app_name.startswith("app"):
    # If app_name is "app1", "app2", etc., use "app_1.py", "app_2.py", etc.
    file_name = f"app_{app_name[3:]}.py"
else:
    # Otherwise, use "app.py" for default or other names
    file_name = f"app_{app_name}.py" if app_name != "default" else "app.py"

print(f"Setting up service for app_name: {app_name}")
print(f"Using file_name: {file_name}")

# Clean up incorrect file names
print("Cleaning up incorrect file names...")
if app_name.startswith("app"):
    # For app2, remove app_app2.py if it exists
    incorrect_file = f"app_app{app_name[3:]}.py"
    if os.path.exists(f"/home/ec2-user/{incorrect_file}"):
        print(f"Removing incorrect file: {incorrect_file}")
        os.remove(f"/home/ec2-user/{incorrect_file}")
else:
    # For other app names, remove any incorrect versions
    incorrect_file = f"app_app_{app_name}.py"
    if os.path.exists(f"/home/ec2-user/{incorrect_file}"):
        print(f"Removing incorrect file: {incorrect_file}")
        os.remove(f"/home/ec2-user/{incorrect_file}")

# Stop all other Flask services with timeout
print("Stopping all other Flask services...")
os.system("sudo systemctl list-units --type=service --all | grep flask-app | grep -v flask-app-" + app_name + " | awk '{print $1}' | xargs -r sudo systemctl stop")

# Kill any process using port 80 with timeout
print("Killing any process using port 80...")
os.system("timeout 5 sudo fuser -k 80/tcp || true")

service_content = f"""[Unit]
Description=Flask App for {app_name}
After=network.target

[Service]
User=root
WorkingDirectory=/home/ec2-user
ExecStart=/usr/bin/python3 /home/ec2-user/{file_name}
Restart=always
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
"""

with open(service_file, "w") as f:
    f.write(service_content)

os.system("sudo systemctl daemon-reload")
os.system(f"sudo systemctl enable flask-app-{app_name}")
os.system(f"sudo systemctl restart flask-app-{app_name}")
print(f"Flask service for {app_name} has been set up and started")

# Check service status but don't wait indefinitely
print("Service status:")
os.system(f"timeout 3 sudo systemctl status flask-app-{app_name} --no-pager || true")
