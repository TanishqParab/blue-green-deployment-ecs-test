import os
import sys

# Get the app name from command line argument
app_name = sys.argv[1] if len(sys.argv) > 1 else "default"

service_file = f"/etc/systemd/system/flask-app-{app_name}.service"

# Determine the correct app file name
if app_name.startswith("app"):
    # If app_name is "app1", use "app_1.py"
    file_name = f"app_{app_name[3:]}.py"
else:
    # Otherwise, use "app_app_name.py"
    file_name = f"app_{app_name}.py"

service_content = f"""[Unit]
Description=Flask App for {app_name}
After=network.target

[Service]
User=root
WorkingDirectory=/home/ec2-user
ExecStart=/usr/bin/python3 /home/ec2-user/{file_name}
Restart=always

[Install]
WantedBy=multi-user.target
"""

with open(service_file, "w") as f:
    f.write(service_content)

os.system("sudo systemctl daemon-reload")
os.system(f"sudo systemctl enable flask-app-{app_name}")
os.system(f"sudo systemctl start flask-app-{app_name}")
print(f"Flask service for {app_name} has been set up and started")
