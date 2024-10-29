### AbuseIPDB Auto-Ban Script for Plesk

A simple script to automatically ban IPs and report abuse to AbuseIPDB, seamlessly integrating with Plesk. 

#### Installation:
1. SSH into your Plesk server.
2. Open the script file for editing:
   ```bash
   nano /usr/local/sbin/abuseipdb.sh
   ```
3. Make the script executable:
   ```bash
   sudo chmod +x /usr/local/sbin/abuseipdb.sh
   ```
4. In Plesk, navigate to **Scheduled Jobs** and set up a cron job with the schedule `*/5 * * * *` to regularly check and report IPs.

#### Command to Run:
```bash
/usr/local/sbin/abuseipdb.sh
```
