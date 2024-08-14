
تبدیل ترموکس به لینوکس با یوزر روت

برای شروع کامند زیر را در ترمینال ترموکس پیست کنید
```
pkg install wget && wget https://github.com/opiran-club/root-termux/setup.sh && chmod +x setup.sh && ./setup.sh
```

بعد از پایان نصب و کانفیگ خودکار شما یک اوبونتو سرور خام دارید که حتما کامند زیر و بزنید

```
apt update && apt upgrade -y
```
و در انتها حتما اپتیمایزر را روی ان اجرا کنید که کلیه پکیجهای لازم را نصب کند با کامند زیر
```
apt install curl -y && bash <(curl -s https://raw.githubusercontent.com/opiran-club/VPS-Optimizer/main/optimizer.sh --ipv4)
```
---------------------------------------------------------------------------------------------------------------------------------------

### Credits
 - credited by [OPIran](https://github.com/opiran-club)

### Contacts
 - Visit Me at [OPIran-Gap](https://t.me/opiranclub)
