import os
import sys
import glob

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

# Debug information
print(f"Setting up service for app_name: {app_name}")
print(f"Using file_name: {file_name}")
print(f"Checking if file exists: {os.path.exists(f'/home/ec2-user/{file_name}')}")

# List files in directory
print("Files in /home/ec2-user:")
os.system("ls -la /home/ec2-user")

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

# Check file content
if os.path.exists(f"/home/ec2-user/{file_name}"):
    print(f"First 10 lines of {file_name}:")
    os.system(f"head -n 10 /home/ec2-user/{file_name}")

# Stop all other Flask services
print("Stopping all other Flask services...")
os.system("sudo systemctl list-units --type=service --all | grep flask-app | grep -v flask-app-" + app_name + " | awk '{print $1}' | xargs -r sudo systemctl stop")

# Kill any process using port 80
print("Killing any process using port 80...")
os.system("sudo fuser -k 80/tcp")

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
# Note: App is configured to run on port 80

[Install]
WantedBy=multi-user.target
"""

with open(service_file, "w") as f:
    f.write(service_content)

os.system("sudo systemctl daemon-reload")
os.system(f"sudo systemctl enable flask-app-{app_name}")
os.system(f"sudo systemctl start flask-app-{app_name}")
print(f"Flask service for {app_name} has been set up and started")

# Check service status
print("Service status:")
os.system(f"sudo systemctl status flask-app-{app_name}")

# Check logs
print("Service logs:")
os.system(f"sudo journalctl -u flask-app-{app_name} -n 20")

# Check if service is listening on port 80
print("Checking port 80:")
os.system("sudo netstat -tulpn | grep :80")
