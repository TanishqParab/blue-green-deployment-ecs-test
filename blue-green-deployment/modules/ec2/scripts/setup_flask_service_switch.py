import os
import sys
import time
import socket
import urllib.request

# Function to fetch EC2 public IP using IMDSv2
def get_instance_public_ip():
    try:
        # Step 1: Fetch token
        token_req = urllib.request.Request(
            "http://169.254.169.254/latest/api/token",
            method="PUT",
            headers={"X-aws-ec2-metadata-token-ttl-seconds": "21600"}
        )
        token = urllib.request.urlopen(token_req).read().decode()

        # Step 2: Use token to get public IP
        metadata_req = urllib.request.Request(
            "http://169.254.169.254/latest/meta-data/public-ipv4",
            headers={"X-aws-ec2-metadata-token": token}
        )
        public_ip = urllib.request.urlopen(metadata_req).read().decode()
        return public_ip
    except Exception as e:
        print(f"⚠️ Failed to retrieve public IP: {e}")
        return None

# Parse arguments
app_name = sys.argv[1] if len(sys.argv) > 1 else "default"
mode = sys.argv[2] if len(sys.argv) > 2 else "switch"

# Normalize the systemd service name
app_suffix = app_name.replace("app", "app_")  # ensures app2 → app_2
service_name = f"flask-app-{app_suffix}"
service_file = f"/etc/systemd/system/{service_name}.service"

# Determine app script
if app_name.startswith("app") and len(app_name) > 3:
    app_number = app_name[3:]
    if mode == "rollback":
        app_script = f"/home/ec2-user/app_app_{app_number}.py"
        print("🛑 Rollback mode triggered")
    else:
        app_script = f"/home/ec2-user/app_{app_number}.py"
        print("🚀 Switch mode triggered (default)")
else:
    app_script = f"/home/ec2-user/app_{app_name}.py"

print(f"App name: {app_name}")
print(f"Mode: {mode}")
print(f"Selected app script: {app_script}")

# Kill anything on port 80
print("⚠️ Killing existing processes on port 80 (if any)...")
os.system("sudo fuser -k 80/tcp 2>/dev/null || true")

# Stop and disable existing service
print(f"🔻 Stopping old service: {service_name}")
os.system(f"sudo systemctl stop {service_name} 2>/dev/null || true")
os.system(f"sudo systemctl disable {service_name} 2>/dev/null || true")

# Create systemd service
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

try:
    with open(service_file, "w") as f:
        f.write(service_content)
    print(f"✅ Created systemd service file: {service_file}")
except PermissionError:
    print("❌ Permission denied: run this script with sudo")
    sys.exit(1)

# Reload systemd and start service
os.system("sudo systemctl daemon-reload")
os.system(f"sudo systemctl enable {service_name}")
os.system(f"sudo systemctl start {service_name}")

# Health check on localhost
print("⏳ Waiting for the app to start on port 80...")
time.sleep(5)

try:
    with urllib.request.urlopen("http://127.0.0.1", timeout=3) as response:
        if response.status == 200:
            print("✅ Flask app responded successfully on localhost.")
        else:
            print(f"⚠️ App responded with status: {response.status}")
except Exception as e:
    print(f"❌ Health check failed on localhost: {e}")

# Public IP check (for LB/ALB testing)
public_ip = get_instance_public_ip()
if public_ip:
    print(f"🌐 Try accessing your app at: http://{public_ip} (via browser or ALB)")
else:
    print("❌ Could not retrieve public IP (IMDSv2 may be restricted)")
