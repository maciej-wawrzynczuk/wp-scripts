# The project description
My private scripts for maitaining WP sites. Feel free to 'get inspired'.
# What it does?
- creates host on AWS EC2 and dns record in Route53
- provisions ready to use WP site including Letsencrypt cert.
- creates S3 bucket for backup/migrations purpose (the 'bucket' directory).
# Prerequisites
- AWS account
- Own domain on Route53
- A lots of patience. ;)
# How to start?
- Create config.yml file - like this:
```
fqdn: host.my.domain
```
- run ''terrafrom init''
- run ''make plan''
- run ''make provision''
- go to your site.
