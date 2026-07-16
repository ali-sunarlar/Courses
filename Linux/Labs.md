## 1. Gün Senaryosu: "Disk Doldu ve Servis Çöktü!"

Bir şirkette Linux Administrator olarak çalişiyorsun. Gece yarisi izleme (monitoring) sisteminden kritik bir alarm aldin: Üretim (Production) ortamindaki bir Ubuntu veri tabani sunucusunda disk alani %100 dolmuş ve PostgreSQL servisi durmuş.

Sunucuya SSH ile bağlandin ve durum şu:

Sunucuda LVM (Logical Volume Manager) yapisi kullaniliyor.

/dev/mapper/vg_prod-lv_data adindaki mantiksal birim (Logical Volume) /var/lib/postgresql dizinine bağli ve tamamen dolu.

Altyapi ekibi sunucuya sanallaştirma ortamindan (VMware/Proxmox vb.) fiziksel olarak 20 GB ek boş disk tanimladi (/dev/sdb olarak sisteme eklendi).

Senden İstenen Adimlar:

Sistemi veri kaybi olmadan ve en kisa sürede ayağa kaldirman gerekiyor. Bana şu adimlari hangi komutlarla ve hangi sira ile yapacağini açikla:

##### 1. Yeni eklenen /dev/sdb diskinin sistem tarafindan işletim sistemi yeniden başlatilmadan (reboot edilmeden) taninip taninmadiğini nasil kontrol edersin?

##### 2. Bu yeni /dev/sdb diskini mevcut LVM yapisina dahil ederek /dev/vg_prod/lv_data birimini 20 GB nasil genişletirsin? (Sirasiyla PV, VG ve LV adimlarini yazmalisin).

##### 3. Disk alanini genişlettikten sonra, dosya sisteminin (örneğin ext4 veya xfs olduğunu varsayarak) bu yeni alani tanimasi için ne yapmalisin?

Son olarak, çöken veri tabani servisini kontrol edip tekrar başlatmak için hangi komutlari kullanirsin?


##### 1. Adim: Diski Reboot Etmeden Tanitmak (Puan: 9/10)

echo 1 > /sys/block/sdb/device/rescan komutu harika bir yöntem. Ancak senaryoda diskin sisteme yeni eklendiğini (/dev/sdb adiyla yeni bir aygit olarak) belirtmiştik. Eğer disk sistemde daha önce hiç yoksa, işletim sisteminin SCSI veri yolunu (bus) tarayarak bu yeni aygiti keşfetmesini sağlamak daha garanti bir yoldur:

```bash
## Tüm SCSI host'lari tarayarak yeni diskleri bulmak için:
echo "- - -" > /sys/class/scsi_host/host0/scan
## (Sistemdeki host0, host1 gibi tüm hostlar için veya kisa bir script ile hepsi için yapilir)

## Ardindan diskin gelip gelmediğini doğrulamak için:
lsblk veya fdisk -l
```

##### 2. Adim: LVM Genişletme (Puan: 5/10) - Buraya Dikkat!

Burada kritik bir mantik hatasi var. Yazdiğin komut: pvresize /dev/sdb.

Hata neden önemli? pvresize, halihazirda LVM içinde olan (Physical Volume yapilmiş) bir diskin boyutu büyüdüğünde kullanilir. Ancak /dev/sdb sisteme yeni eklenen, tamamen yabanci bir disk.

Doğru siranin şu şekilde olmasi gerekirdi:

Yeni diski LVM formatina hazirla (Physical Volume oluştur):

```bash
pvcreate /dev/sdb
``` 

Bu yeni PV'yi mevcut Volume Group'a (vg_prod) ekle (Genişlet):

```bash
vgextend vg_prod /dev/sdb
```

Şimdi Logical Volume'u genişlet (Senin yazdiğin komut tam olarak doğru!):

```bash
lvextend -l +100%FREE /dev/mapper/vg_prod-lv_data
``` 


##### 3. Adim: Dosya Sistemini Büyütmek (Puan: 10/10)

Burasi kusursuz. xfs_growfs ve resize2fs ayrimlarini tam olarak doğru yaptin.
Küçük bir SysAdmin ipucu: lvextend komutunun sonuna -r (veya --resizefs) parametresini eklersen, LVM genişleme biter bitmez dosya sistemini (ext4 veya xfs fark etmeksizin) arka planda otomatik olarak büyütür. Tek komutla iki işi halletmiş olursun:

```bash
lvextend -l +100%FREE -r /dev/mapper/vg_prod-lv_data
```

##### 4. Adim: Servis Kontrolü ve Log Analizi (Puan: 10/10)

systemctl status ile durumu kontrol etmek ve loglara bakmak en doğru pratik. journalctl -u postgresql veya postgresql'in kendi log dizinine (/var/log/postgresql/) bakarak disk doluluğundan dolayi veri tabaninda bir bozulma (corruption) olup olmadiğini incelemen gerekir. Ardindan 
```sh
systemctl start postgresql 
```
ile servisi ayağa kaldirabilirsin.


## 2. Gün: Kullanici Yönetimi, İzinler ve Güvenlik Sikilaştirma (Hardening)

2. Gün Senaryosu: "Geliştirici Erişimi ve Yetki Sinirlandirmasi"

Şirkete yeni katilan kidemli bir yazilimci var. Adi: umut. Umut'un bu veri tabani sunucusunda çalişmasi gerekiyor ancak sistemde tam yetkili (root) olmasini istemiyoruz.
Senden İstenen Adimlar:

##### 1. umut adinda bir kullanici oluştur. Bu kullanicinin varsayilan kabuğu (shell) bash olsun.

##### 2. Umut'un sadece ve sadece systemctl restart postgresql ve systemctl status postgresql komutlarini sudo yetkisiyle (şifre girerek veya şifresiz) çaliştirmasina izin vermek istiyorsun. Diğer hiçbir sudo komutunu (örneğin sudo apt update veya sudo su) çaliştiramamali. Bunu /etc/sudoers veya /etc/sudoers.d/ altinda nasil yapilandirirsin? (Satiri tam yazmani bekliyorum).

##### 3. Güvenlik denetiminde (audit), sistemdeki bazi kritik dosyalarin izinleri inceleniyor. /etc/passwd ve /etc/shadow dosyalarinin izinleri (permission) ve sahiplikleri (owner/group) normal şartlarda ne olmalidir? Güvenli olup olmadiklarini hangi komutla kontrol edersin?



##### 1. Adim: Kullanici Oluşturma (Puan: 10/10)

```useradd -m -s /bin/bash``` umut komutu kesinlikle doğru. -m ile home dizinini oluşturdun, -s ile de varsayilan shell'i belirledin.

##### 2. Adim: Sudo Yetkilendirmesi (Puan: 9/10)

Yazdiğin satir mantik olarak tamamen doğru:
```umut ALL=(ALL) NOPASSWD: /bin/systemctl restart postgresql, /bin/systemctl status postgresql```

Buradaki Küçük Güvenlik Riski (Senior Detayi):
systemctl status postgresql komutu çaliştirildiğinda, eğer çikti ekrana siğmayacak kadar uzunsa sistem otomatik olarak bunu less veya more gibi bir sayfalayici (pager) ile açar. less komutu sudo yetkisiyle çaliştiğinda, kullanici ! tuşuna basarak root kabuğuna (shell bypass) düşebilir!

Bunu engellemek için kurumsal dünyada sudoers satirina SYSTEMD_PAGER kisitlamasi eklenir veya sadece restart yetkisi verilir. Ayrica bu kurali doğrudan /etc/sudoers içine yazmak yerine, /etc/sudoers.d/umut adinda ayri bir dosya oluşturup içine yazmak en temiz yönetim şeklidir (Best Practice).


##### 3. Adim: Dosya İzinleri ve Güvenlik Denetimi (Puan: 8/10)

ls -l ile kontrol etmek en temel ve doğru yöntem. Peki kurumsal bir denetimde (audit) karşina çikmasi gereken ideal senaryo nedir?

/etc/passwd: Sistemdeki tüm kullanicilarin temel bilgilerini içerir. Herkesin okuyabilmesi gerekir ama sadece root yazabilmelidir.

İdeal İzin: 644 (-rw-r--r--)
Sahibi/Grubu: root:root

/etc/shadow: Kullanici şifrelerinin hash'lenmiş hallerini barindirir. Çok kritiktir. Siradan kullanicilar kesinlikle okuyamamalidir.

İdeal İzin: 640 (-rw-r-----) veya bazi dağitimlarda 600 (-rw-------)

Sahibi/Grubu: root:shadow (veya root:root)

Eğer denetimde bu dosyalardan birinin izni örneğin 777 veya 666 çikarsa, o sunucu doğrudan kirmizi alarm verir.




## 3. Gün: Ağ Yönetimi ve Sorun Giderme (Networking & Troubleshooting)

Kullanici yönetimini de başariyla tamamladik. Şimdi bir Linux yöneticisinin mesaisinin en az %30'unu kaplayan alana geliyoruz: Network sorunlari.
3. Gün Senaryosu: "Uygulama Sunucusu Veri Tabanina Bağlanamiyor!"

Yazilim ekibi (umut ve arkadaşlari) yeni bir mikroservis yayina aldi. Ancak uygulama loglarinda sürekli şu hatayi aliyorlar: Connection timed out: database.internal:5432.

Uygulamanin çaliştiği Ubuntu Linux sunucusuna SSH ile bağlandin. Sorunun network katmaninda mi, DNS'te mi yoksa karşi sunucuda mi olduğunu bulman gerekiyor.


Senden İstenen Adimlar:

##### 1. İlk olarak, uygulama sunucusunun database.internal alan adinin IP adresini doğru çözüp çözemediğini (DNS sorununu) hangi komutlarla kontrol edersin? (En az 2 alternatif komut).

##### 2. DNS'in doğru IP'yi çözdüğünü varsayalim (Örn: 10.0.0.50). Ancak sorun devam ediyor. Karşi sunucunun 5432 portunun erişilebilir olup olmadiğini, yani arada bir firewall (güvenlik duvari) engeli veya port kapanmasi olup olmadiğini ping komutu dişinda hangi komutlarla test edersin?

##### 3. Eğer sorun uzak sunucuda değil de, bizim kendi uygulama sunucumuzun üzerindeki yerel bir firewall'dan (ufw veya iptables) kaynaklaniyorsa, sunucudaki aktif firewall kurallarini listelemek ve durumunu görmek için hangi komutlari kullanirsin?


##### 1. Adim: DNS Sorun Giderme (Puan: 10/10)

Burada tam puan aldin, çünkü sadece komut söylemekle kalmadin, Linux'un isim çözümlleme (name resolution) mekanizmasinin arka planina baktin.

Siralama Mantiği: Linux bir domaini çözmek istediğinde önce ```/etc/nsswitch.conf``` dosyasina bakar. Burada genellikle files dns yazar. Yani sistem önce ```/etc/hosts``` (files) dosyasina, orada bulamazsa ```/etc/resolv.conf``` (dns) içindeki DNS sunucularina sorar. Bu sirayi kontrol etmen mükemmel.

Komut Alternatifleri: nslookup harika. Modern sistemlerde bunun yanina dig database.internal veya host database.internal komutlarini da ekleyebiliriz. dig komutu DNS sunucusundan dönen tüm detaylari (TTL, Query Time vb.) verdiği için troubleshooting esnasinda çok sevilir.

##### 2. Adim: Port ve Erişilebilirlik Kontrolü (Puan: 8/10) - Küçük Bir Detay

telnet ve curl kullanimi networkçülerin vazgeçilmezidir. telnet database.internal 5432 komutu bağlanti durumunu net olarak gösterir.

Ancak ss komutunda bir hedef şaşirmasi var:

Senaryomuzda biz Uygulama Sunucusundayiz ve uzak veri tabani sunucusuna bağlanmaya çalişiyoruz.

Yazdiğin ```ss -tulpn | grep 5432``` komutu, üzerinde bulunduğun sunucunun 5432 portunu dinleyip dinlemediğini (LISTEN) kontrol eder. Uygulama sunucusunda PostgreSQL kurulu olmadiği için bu komut boş dönecektir ve bu normaldir. Uzak sunucudaki portu yerelde ss ile göremeyiz.

Peki telnet dişinda uzak portu taramak için ne kullanabilirdin?

En popüler ve güçlü araç nc (netcat) veya nmap olurdu:

```bash
nc -zv database.internal 5432
## veya
nmap -p 5432 database.internal
```

##### 3. Adim: Yerel Firewall Kontrolü (Puan: 9/10)

"Yerel firewall açik mi değil mi kontrol ederim" dedin, çok doğru. Peki bunu hangi komutlarla yapardin? Kurumsal dünyada Ubuntu üzerinde varsayilan olarak UFW (Uncomplicated Firewall) veya arka planda iptables/nftables bulunur.

Kullanman gereken komutlar şunlar olmaliydi:

```bash
## UFW durumunu ve kurallarini görmek için:
sudo ufw status verbose

## Eğer ufw aktif değil ama iptables kurallari varsa:
sudo iptables -L -n -v
```

## 4. Gün Senaryosu: "Özel Script Loglari Diski Şişiriyor"

Şirketteki DevOps ekibi, sunucuda arka planda sürekli çalişan ve log üreten özel bir Python uygulamasi (script) çaliştirdi. Bu uygulama bir Systemd Servisi olarak yapilandirilmiş.

Ancak uygulama loglarini standart journald yerine doğrudan /var/log/my_app.log dosyasina yaziyor. Uygulama çok canli olduğu için bu log dosyasi günde 5 GB büyüyor ve birkaç güne diski yine bitirecek!
Senden İstenen Adimlar:

##### 1. Bu Python uygulamasinin Systemd servis adinin myapp.service olduğunu varsayalim. Bu servisin şu an çalişip çalişmadiğini, sistem başlangicina (boot) eklenip eklenmediğini (enable/disable) nasil kontrol edersin?

##### 2. Bu /var/log/my_app.log dosyasinin diski doldurmasini engellemek için Linux'un yerleşik logrotate mekanizmasini kullanmak istiyorsun. Loglarin günlük (daily) olarak döndürülmesini (rotate), eski loglarin sikiştirilmasini (compress) ve sistemde en fazla 7 günlük log tutulmasini istiyorsun. /etc/logrotate.d/myapp adinda bir dosya oluşturup içine yazman gereken konfigürasyonu bana taslak olarak gösterebilir misin?

##### 3. logrotate konfigürasyonunu yazdiktan sonra, bir hata olup olmadiğini görmek ve sistemi test etmek için bu kurali elle (manually) ve zorla (force) nasil çaliştirirsin?


##### 1. Adim: Servis Durumu ve Boot Kontrolü (Puan: 10/10)

systemctl status myapp.service komutu tam olarak doğru. Çiktida bahsettiğin loaded (...; enabled; ...) ibaresi servisinin boot sirasinda otomatik başlayacağini gösterir.

Eğer disabled görseydin, bunu aktifleştirmek için şu komutu kullanacaktin:

```bash
sudo systemctl enable myapp.service
```

##### 2. Adim: Logrotate Konfigürasyonu (Yeni Bilgi 🚀)

Linux'ta loglarin diski şişirmesini önlemek için logrotate servisi kullanilir. ```/etc/logrotate.d/``` dizini altina uygulaman için bir dosya açarsin ve kurallari yazarsin.

Senaryomuzdaki istekler şunlardi: Günlük dönsün, sikiştirilsin ve en fazla 7 gün tutulsun.

```/etc/logrotate.d/myapp``` dosyasinin içeriği tam olarak şöyle olmalidir:

```bash
/var/log/my_app.log {
    daily
    rotate 7
    compress
    missingok
    notifempty
    copytruncate
}
```

Bu parametreler ne anlama geliyor?

daily: Log döndürme işlemi her gün yapilsin.

rotate 7: Sistemde en fazla 7 eski log dosyasi tutulsun (8. gün, en eski olan silinir).

compress: Eski loglar yer kaplamasin diye .gz formatinda sikiştirilsin.

missingok: Eğer log dosyasi o gün henüz oluşmadiysa hata verme, sessizce geç.

notifempty: Eğer log dosyasi boşsa (0 byte) boşuna döndürme işlemi yapma.

copytruncate: (En kritik SysAdmin numarasi!) Python uygulamasi log dosyasini sürekli açik tuttuğu için, dosyayi direkt silersek uygulama log yazmayi birakabilir. Bu parametre, mevcut logun bir kopyasini alir ve orijinal dosyanin içini boşaltir (truncate). Uygulama kesintisiz yazmaya devam eder.


##### 3. Adim: Logrotate Kuralini Elle ve Zorla Test Etmek (Yeni Bilgi 🚀)

Yazdiğin bu kuralin çalişip çalişmadiğini gece yarisini beklemeden hemen test etmek istersin. Bunun için logrotate komutuna bazi parametreler veririz:


```bash
sudo logrotate -f /etc/logrotate.d/myapp
```

-f (or --force): Logrotate'e "Normalde zamani gelmedi ama sen kurallari hiçe say ve bu logu şimdi, zorla döndür" talimati verir.

Bu komuttan sonra /var/log/ dizinine gidip ls -l yaparsan, my_app.log.1.gz adinda sikiştirilmiş ilk eski logunu görebilirsin.



## 5. Gün: Süreç Yönetimi ve Performans Analizi (Process Management & Troubleshooting)

Harika bir araç daha öğrendik. Şimdi sunucunun donanim kaynaklarini (CPU/RAM) sömüren durumlari tespit etme günümüz.
5. Gün Senaryosu: "Sunucu Kilitleniyor, CPU %100!"

Müşteriler web sitesine girmeye çaliştiğinda "502 Gateway Error" aliyor. Sunucuya zar zor SSH attin, terminal aşiri yavaş tepki veriyor. Belli ki içeride sistemi boğan bir şeyler var.
Senden İstenen Adimlar:

##### 1. Sunucudaki anlik CPU, Bellek (RAM) kullanimini ve en çok kaynak tüketen süreçleri (process) canli olarak izlemek için hangi terminal aracini/araçlarini (top dişinda daha modern bir alternatif de olabilir) kullanirsin?

##### 2. İncelemende, zombi_islem adinda bir Python script'inin arka arkaya onlarca süreç açtiğini ve CPU'yu %100 tükettiğini gördün. Bu sürecin PID (Process ID) numarasinin 4523 olduğunu varsayalim. Bu süreci sistemden en agresif ve kesin şekilde (sinyal göndererek) nasil sonlandirirsin (öldürürsün)?

##### 3. Bazen bir süreç (process) arka planda takili kalir ama o an hangi dosyalari okuduğunu veya hangi network portunu kullandiğini bilmek isteriz. Çalişan bir PID'nin (örneğin yine 4523) sistemde açtiği tüm dosyalari ve network soketlerini listelemek için hangi Linux komutunu kullanirsin?



##### 1. Adim: Canli Sistem İzleme (Ezber Bozan Modern Araçlar)

Sistem kilitlendiğinde veya yavaşladiğinda top komutu varsayilan olarak her Linux'ta bulunur ama okunmasi zordur. Kurumsal dünyada tüm SysAdmin'lerin ilk yüklediği modern araç htop'tur.

Terminale ```htop``` yazdiğinda karşina renkli, CPU çekirdeklerini tek tek gösteren, RAM kullanimini bar şeklinde veren ve süreçleri kolayca siralayabileceğin interaktif bir ekran gelir.

Eğer sunucuda htop yoksa, anlik disk trafiğini görmek için iotop, network trafiğini görmek için ise iftop komutlarini kullaniriz.


##### 2. Adim: Süreçleri Sonlandirmak ve Zombi İşlemler (Yeni Bilgi 🚀)

Bir süreci en agresif şekilde öldürmek için ona SIGKILL (9) sinyali göndeririz. Bu sinyal sürece "işini bitirmeni beklemiyorum, hemen kapan" der.

```bash
## 4523 PID'li süreci kesin olarak öldürmek için:
sudo kill -9 4523
```

Zombi İşlem (Zombie Process) Nedir ve Nasil Tespit Edilir?
Linux'ta bir alt süreç (child process) görevini bitirdiğinde, işletim sistemine "ben bittim" der. Ancak onu başlatan ana süreç (parent process) bu cevabi alip onaylamazsa, o alt süreç sistemde "Zombi" olarak kalir. RAM veya CPU tüketmezler ama sistemin süreç tablosunda yer kaplarlar.

Tespit Etmek: Terminale top veya htop yazdiğinda sağ üst köşede ```Tasks: ... total, ... running, ... sleeping, 2 zombie``` gibi bir ibare görürsün.

Eğer sistemdeki zombi işlemlerin PID numaralarini listelemek istersen şu komutu kullanirsin:

```bash
ps aux | awk '{ print $8 " " $2 }' | grep -i Z
```

(Burada durum kodu Z olan süreçler zombidir. Zombi işlemler ```kill -9``` ile doğrudan ölmezler, çünkü zaten ölüdürler! Onlari temizlemek için onlari doğuran ana süreci (Parent PID) bulup yeniden başlatmak gerekir).



3. Adim: Bir Sürecin Açtiği Dosyalari Bulmak (Yeni Bilgi 🚀)

Linux dünyasinda her şey bir dosyadir (klasörler, network soketleri, donanimlar...). Bir sürecin arka planda ne kariştirdiğini görmek için ```lsof``` (List Open Files) komutunu kullaniriz. SysAdmin'lerin en çok kullandiği komutlardan biridir.

```bash
## 4523 PID'li sürecin açik tuttuğu tüm dosyalari ve network bağlantilarini listeler:
sudo lsof -p 4523
```


## 6. Gün: Zamanlanmiş Görevler ve Otomasyon (Cronjobs & Bash Scripting)

Şimdiye kadar disk kurtardin, kullanici yetkilendirdin, network çözdün, log döndürdün ve süreçleri yönettin. Şimdi bunlari otomatize etme zamani.
6. Gün Senaryosu: "Otomatik Yedekleme ve Temizlik"

Şirket, her gece yarisi saat 03:00'te /var/www/html dizininin yedeğinin (tar.gz formatinda) alinmasini ve /backup dizinine yüklenmesini istiyor. Ayrica diskte yer kaplamasin diye /backup dizinindeki 30 günden eski yedeklerin otomatik silinmesini istiyorlar.
Senden İstenen Adimlar:

##### 1. /backup dizini altindaki 30 günden eski ve ismi .tar.gz ile biten dosyalari bulup tek komutla silecek o meşhur find komutunu nasil yazarsin?

##### Bu işlemi otomatikleştirmek için Linux'un zamanlanmiş görev servisi olan Cron'u kullanacağiz. crontab -e komutu ile editörü açtiğini varsayalim. Her gece saat 03:00'te çalişacak bir görevi (cron satirini) nasil tanimlarsin? (Zamanlama yildizlarini * * * * * mantiğina göre dizmeni bekliyorum).

İpucu: Cron zamanlamasi Dakika Saat Ayin_Günü Ay Haftanin_Günü şeklindedir.


##### 1. Adim: Eski Dosyalari Bulup Silmek (Puan: 10/10)

```find /backup -type f -name "*.tar.gz" -mtime +30 -exec rm -f {} \;```

Bu komut adeta bir İsviçre çakisidir ve tam puani hak ediyor.

```-type f```: Sadece dosyalari hedef alarak dizinleri yanlişlikla silmeni engeller.

```-name "*.tar.gz"```: Sadece yedek dosyalarini seçer, yapilandirma veya diğer önemli dosyalari korur.

```-mtime +30```: Değiştirilme zamani (modification time) 30 günden eski olanlari filtreler.

```-exec rm -f {} \;```: Bulunan her bir dosyayi ({}) sirayla güvenli ve zorlayici şekilde (rm -f) siler. \; ise komutun bittiğini find mekanizmasina bildirir.


##### 2. Adim: Cron Zamanlamasi ve Akilli Alternatif (Puan: 10/10)

```0 3 * * * find /backup -type f -name "*.tar.gz" -mtime +30 -delete```

Kesinlikle kullanabilirsin ve hatta bu çözüm 1. adimdaki yöntemden daha performanslidir!

Zamanlama (``` 0 3 * * * ```): Tam olarak her gece saat 03:00'ü ifade eder.

```-delete``` Parametresi (Senior Detayi): İlk adimda yazdiğin ```-exec rm -f {} \;``` yöntemi, bulunan her dosya için arka planda yeni bir rm süreci (process) başlatir. Eğer silinecek binlerce dosya varsa bu durum sistemi yorabilir. Ancak senin cron içine yazdiğin -delete parametresi, yerleşik (built-in) bir find yeteneğidir. Yeni bir süreç başlatmadan dosyalari doğrudan siler. Çok daha hizli ve sistem dostudur.




## 7. Gün: Paket Yönetimi ve Bağimlilik Çözme (Package Management & Troubleshooting)

İlk haftayi harika kapattin! Temel operasyonlari cebe koyduğumuza göre, şimdi sistem güncellemeleri ve uygulama kurulumlari sirasinda başimiza gelen o can sikici krizlerden birine odaklanalim.
7. Gün Senaryosu: "Paket Yöneticisi Kilitlendi!"

Sunucuya yeni bir güvenlik yamasi geçmek veya bir paket kurmak istiyorsun. Terminalde ``sudo apt update`` veya ``sudo apt install nginx`` komutunu çaliştirdin. Ancak komut ilerlemiyor ve terminalde şu meşhur hata firlatiliyor:

```E: Could not get lock /var/lib/dpkg/lock-frontend. It is held by process 1234 (unattended-upgr)```

Senden İstenen Adimlar:

#### 1. Bu hata tam olarak ne anlama geliyor? Linux neden ayni anda ikinci bir yükleme işlemine izin vermiyor?

#### 2. Hata çiktisinda bu kilidi tutan sürecin PID numarasinin `1234` ve adinin ``unattended-upgr`` (otomatik güncellemeler) olduğu açikça yaziyor. Bu durumda kilidi açip kendi kurulumuna güvenli bir şekilde devam etmek için sirasiyla ne yaparsin? (Süreci hemen öldürmeli miyiz, yoksa başka bir yolu var mi?)


#### 1. Adim: Bu Hata Ne Anlama Geliyor? (Yeni Bilgi 🚀)

Linux (özellikle Debian/Ubuntu tabanli sistemler) paket bütünlüğünü korumak konusunda çok katidir.

Neden Kilitlenir? Ayni anda iki farkli programin sistem dosyalarini değiştirmesini, veritabanini bozmasini engellemek için `apt` veya `dpkg` çalişmaya başladiğinda bazi kritik dosyalara (örneğin ``/var/lib/dpkg/lock-frontend``) bir "kilit" (`lock`) koyar. İşlem bitene kadar başka hiç kimse paket yükleyemez veya silemez.

Hata mesajindaki ``unattended-upgr`` (Unattended Upgrades), Ubuntu'nun arka planda otomatik olarak güvenlik güncellemelerini indiren yerleşik bir servisidir. Sunucu arka planda kendi kendine güvenlik yamasi yaparken sen araya girip apt çaliştirmaya çaliştiğin için sistem seni engelliyor.


#### 2. Adim: Kilidi Açmak İçin İzlenecek Doğru Yol (Puan: 9/10)

"Loguna bakarim, takilmiş mi kontrol ederim" yaklaşimin tam isabet. Bu durumda izlenmesi gereken profesyonel sira şudur:

1. Yol: Sabirla Beklemek (En Güvenlisi)
Arka plandaki işlem (``unattended-upgr``) bir güvenlik güncellemesi yapiyor. Eğer sunucu o an kritik bir sistem kütüphanesini güncelliyorsa ve biz bu işlemi yarida kesersek sistem dosyalari bozulabilir. Bu yüzden ilk kural 1-2 dakika beklemektir. Genelde güncelleme biter, kilit kalkar ve senin komutun çalişir.

2. Yol: Servis Durumunu Kontrol Etmek (Senin Söylediğin Mantik)
Bekledin ama kilit açilmiyor. Sürecin gerçekten takilip kalip kalmadiğini görmek için servisin durumuna bakariz:


```bash
sudo systemctl status unattended-upgrades
```


3. Yol: Süreci Nazikçe Durdurmak (Graceful Shutdown)
Eğer acelen varsa ve servisi kapatmak istiyorsan, süreci kill -9 ile vahşice öldürmek yerine servise durma talimati verirsin. Böylece yaptiği işi güvenli bir noktada kaydeder ve durur:
```Bash
sudo systemctl stop unattended-upgrades
```

Asla Yapilmamasi Gereken (Junior Hatasi):
İnternetteki bazi forumlarda bu hata için doğrudan ```rm -f /var/lib/dpkg/lock-frontend``` (kilit dosyasini zorla sil) komutunu önerirler. Arka plandaki işlem hala çalişirken o dosyayi silmek, paket veritabaninin (apt database) bozulmasina yol açar ve bir daha sunucuya hiçbir şey kuramayabilirsin. Kilit dosyasi sadece ve sadece arka planda hiçbir sürecin çalişmadiğindan %100 emin olunduğunda silinebilir.










## 8. Gün: Dosya Sistemi Sağliği ve "Inbound/Outbound" Kavramlari (Inode ve Disk Sorunlari)

İlk haftayi geride biraktik ve harika bir temel attik. Şimdi seni mülakatlarda ve gerçek krizlerde en çok terletecek, "görünmez" bir disk problemine götürüyorum.
8. Gün Senaryosu: "Diskte Yer Var Ama Dosya Oluşturulamiyor!"

Yazilim ekibi yine panikle geldi. Sunucuya bir dosya yazmaya çalişiyorlar ve sistem ``No space left on device`` (Diskte boş yer kalmadi) hatasi veriyor.

Sunucuya bağlandin ve ilk gün öğrendiğin gibi df -h komutunu çaliştirdin. Gördüğün sonuç seni şaşirtti: Disk kullanim orani sadece %40. Yani diskte fersah fersah boş yer var!

Senden İstenen Adimlar:

##### 1. ``df -h`` komutu diskte bolca boş yer olduğunu söylerken, işletim sistemi neden "Yer yok" hatasi veriyor olabilir? Linux dosya sistemindeki hangi yapisal sinir (limit) aşilmiş olabilir?

#### 2. Bu şüpheyi doğrulamak için, diskin bu bahsettiğimiz yapisal doluluk oranini hangi komutla (hangi parametre ile) kontrol edersin?

#### 3. Eğer tahmin ettiğimiz şey dolduysa, buna genellikle milyonlarca çok küçük boyutlu dosya (örneğin session dosyalari veya küçük loglar) neden olur. Sunucuda en çok dosya barindiran dizini bulmak için nasil bir strateji izlersin?


#### 1. Adim: Sorunun Kaynaği Nedir? (Görünmez Limit: Inode)

Linux'ta bir dosya sistemi (ext4, xfs vb.) oluşturulduğunda, disk sadece Gigabyte (GB) cinsinden bir alana bölünmez; ayni zamanda Inode (Index Node) adi verilen sabit sayida "kimlik karti/indeks numarasi" oluşturulur.

Linux'ta her bir dosya ve klasör için tam olarak 1 adet Inode (indeks numarasi) harcanir. Dosyanin boyutu ister 10 GB olsun, ister 1 Byte olsun fark etmez; o dosya sistemde bir yer kapliyorsa 1 Inode tüketir.

Krizin Nedeni: Eğer bir uygulama (örneğin PHP session'lari, cache servisleri veya mikroservisler) diskte milyonlarca 0 byte veya çok küçük boyutlu dosya oluşturursa, diskte GB cinsinden yer bitmeden önce sunucunun üretebileceği Inode (indeks numarasi) sayisi biter. * Sonuç olarak: ``df -h`` yaptiğinda disk %40 dolu görünür (çünkü GB olarak yer vardir) ama yeni bir dosya oluşturmak istediğinde sistem ona kimlik numarasi (Inode) veremediği için ``No space left on device`` hatasi firlatir.


2. Adim: Inode Doluluğunu Kontrol Etmek (Yeni Bilgi 🚀)

Diskin GB cinsinden doluluğuna ``df -h`` (human-readable) ile bakiyorduk. Inode doluluk oranini görmek için ise komuta `-i` parametresini ekleriz:
```Bash
df -i
```
Bu komutu çaliştirdiğinda karşina yine disk bölümleri gelir ama bu sefer GB değil, ``IUsed`` (Kullanilan Inode sayisi), ``IFree`` (Boşta olan Inode sayisi) ve IUse% (Inode kullanim yüzdesi) değerlerini görürsün. Sorunumuzun olduğu sunucuda bu oran %100 görünecektir.


3. Adim: Milyonlarca Küçük Dosyayi Bulan SysAdmin Stratejisi (Yeni Bilgi 🚀)

Sorunu teşhis ettik; içeride bir yerde milyonlarca küçük dosya var ve bunlari bulup silmemiz gerekiyor. Klasik ``du -sh`` komutu dosya boyutuna baktiği için burada işe yaramaz. Bize dosya sayisini sayacak bir komut lazim.

Bunun için ilgili dizinlerde (genelde ``/var/log``, ``/tmp`` veya ``/var/lib``) şu sihirli script'i çaliştiririz:
```Bash
find /var -xdev -type f | cut -d "/" -f 2,3,4 | sort | uniq -c | sort -nr | head -n 10
```
Bu komut ne yapiyor?

1. ``/var`` dizini altindaki tüm dosyalari (``-type f``) buluyor.

2. ``cut`` ve ``sort`` kullanarak bu dosyalarin hangi alt klasörlerde toplandiğini sayiyor (``uniq -c``).

3. En çok dosyaya sahip olan ilk 10 klasörü büyükten küçüğe listeleyerek (``head -n 10``) sana teslim ediyor.

Çiktida örneğin ``/var/lib/php/sessions`` klasörünün yaninda 2.500.000 gibi bir rakam görürsün. Katili buldun! O klasörün içindeki eski session dosyalarini sildiğin an Inode'lar serbest kalir ve sunucu nefes alir.


## 9. Gün: Yedekleme ve Dosya Transferi (Rsync ve Güvenli Aktarım)

Harika bir derin dünya bilgisini cebe attık. Şimdi kurumsal ortamlarda her gün yaptığımız bir işe geçelim: Veri taşıma ve yedekleme.
9. Gün Senaryosu: "Sunucu Göçü (Migration)"

Şirket, eskiyen bir dosya sunucusundaki (File Server) verileri yeni kurulan daha güçlü bir Linux sunucusuna taşımaya karar verdi. Eski sunucudaki ``/mnt/storage`` dizini altında tam 2 TB büyüklüğünde veri var. Bu verilerin içinde milyonlarca PDF, Word dosyası ve klasör yapısı bulunuyor.

Senden istenen, bu verileri ağ üzerinden yeni sunucuya (IP: ``10.0.0.90``) güvenli bir şekilde aktarman.

Senden İstenen Adımlar:

#### 1. Bu devasa veriyi kopyalarken ağ kesilebilir, bağlantı kopabilir. Kaldığı yerden devam edebilen, dosyaların izinlerini (permissions), sahipliklerini (owner) ve zaman damgalarını (timestamp) aynen koruyarak kopyalayan o popüler Linux dosya transfer aracı hangisidir?

#### 2. Bu aracı kullanarak, eski sunucudaki ``/mnt/storage`` dizinini, yeni sunucudaki (10.0.0.90) ``/backup/storage`` dizinine gönderecek komutu (kopyalama ilerlemesini ekranda yüzde olarak görmek de isteyerek) nasıl yazarsın?

#### 3. İlk kopyalama 20 saat sürdü ve bitti. Aradan 2 gün geçti. Canlı sistem olduğu için eski sunucuya bu 2 günde yeni dosyalar eklendi. Yeni sunucuya sadece değişen veya yeni eklenen dosyaları senkronize etmek (farkı kapatmak) için komuta özel bir şey eklemene gerek var mı, yoksa araç bunu kendisi halledebiliyor mu?


#### 1. Adım: Linux'un Robocopy'si: Rsync (Puan: 10/10)

``rsync`` tahminin kesinlikle doğru. Kurumsal Linux dünyasında sunucular arası veri transferinin, yedeklemenin ve replikasyonun 1 numaralı aktörüdür.



2. Adım: Rsync ile Doğru Taşımacılık (Yeni Bilgi 🚀)

2 TB'lık devasa bir veriyi, tüm izinleriyle (ACL, kullanıcı sahiplikleri, oluşturulma tarihleri vb.) karşı sunucuya (``10.0.0.90``) taşımak ve ekranda ne kadar bittiğini (yüzdeyi/hızı) görmek için şu komutu kullanırız:


```Bash
rsync -avzP /mnt/storage/ root@10.0.0.90:/backup/storage/
```


Bu parametreler ne işe yarıyor? (SysAdmin Sözlüğü):

`-a` (archive): En kritik parametre. Robocopy'deki ``/COPYALL`` gibidir. Alt dizinleri tarar, sembolik linkleri korur, dosya izinlerini (``chmod``), sahipliklerini (``chown``) ve zaman damgalarını aynen karşıya geçirir.

`-v` (verbose): O an hangi dosyanın kopyalandığını ekranda canlı gösterir.

`-z` (compress): Verileri ağ üzerinden göndermeden önce sıkıştırır, karşı tarafta açar. Ağ trafiğini (bandwidth) ciddi oranda azaltır.

`-P` (progress & partial): Senin istediğin parametre. Hem ekranda anlık kopyalama hızını ve yüzdeyi (%) gösterir, hem de ağ koparsa kopyalamanın kaldığı yerden (yarıda kalan dosyayı çöpe atmadan) devam etmesini sağlar.



3. Adım: Sadece Değişenleri Eşitlemek (Fark Delta Senkronizasyonu)

Sorunun cevabı: Evet, ``rsync`` bunu hiçbir ek parametreye ihtiyaç duymadan varsayılan olarak kendisi yapar!

Aynı komutu 2 gün sonra tekrar çalıştırdığında:


```Bash
rsync -avzP /mnt/storage/ root@10.0.0.90:/backup/storage/
```



``rsync`` ilk olarak iki sunucudaki dosyaların boyutlarını ve değişiklik tarihlerini jet hızıyla karşılaştırır.

Karşı tarafta aynısı olan dosyalara dokunmaz (üzerinden atlar).

Sadece yeni eklenen veya içeriği değişen dosyaları ağdan gönderir.

Hatta bir dosyanın sadece sonuna 3 satır eklendiyse, tüm dosyayı değil sadece o değişen 3 satırlık blokları (``Delta Transfer``) gönderir. Bu yüzden 2 TB'lık ilk aktarım 20 saat sürdüyse, sonraki günlerdeki senkronizasyon sadece birkaç dakika sürer.



## 10. Gün: Log Analizi ve Metin Filtreleme (Grep, Sed, Awk ile Hata Avcılığı)

Yedeklemeyi de cebe koyduk. Şimdi, bir SysAdmin'in günlük hayatta en çok zaman geçirdiği, "bize gelen bir log yığınından samanlıkta iğne arama" konusuna geliyoruz.
10. Gün Senaryosu: "Saldırı Altındayız! Kim Bu IP'ler?"

Şirketin ana web sunucusuna (Nginx) yoğun bir trafik geliyor ve web sitesi yavaşladı. ``/var/log/nginx/access.log`` dosyasında saniyede yüzlerce satır akıyor. Birilerinin sunucuya botlarla kaba kuvvet (Brute Force) veya DDoS saldırısı yaptığından şüpheleniyorsun.

Log satırları standart olarak şu formatta akıyor:
```192.168.1.150 - - [08/Jun/2026:12:00:01 +0300] "GET /login HTTP/1.1" 401 2340```
Senden Иstenen Adımlar:

#### 1. Bu log dosyasının içinden, sadece içinde "POST /login" (yani giriş yapmayı deneyen) ve "401" (hatalı şifre/yetkisiz) ifadesi geçen satırları filtreleyip ekrana basmak için hangi Linux komutunu kullanırsın?

#### 2. Log dosyası o kadar büyük ki ekrana sığmıyor. Bu log dosyasının sadece en son eklenen 50 satırını canlı olarak (yeni loglar geldikçe ekranda akacak şekilde) nasıl takip edersin?

#### 3. (İleri Düzey Sorusu): Bu devasa log dosyasındaki tüm IP adreslerini (satırın en başındaki ilk sütunu) ayıklayıp, hangi IP'nin kaç kere saldırdığını büyükten küçüğe sıralamak için hangi komut zincirini (piping - |) kullanırsın?

Küçük bir ipucu: ``awk`` ile ilk sütunu alabilir, ``sort`` ve ``uniq`` kullanabilirsin.




#### 1. Adım: Log İçinde Kelime Filtreleme (Grep Mucizesi)

Bir log dosyasında belirli kelimeleri aramak için ``grep`` komutunu kullanırız. Bizim senaryomuzda hem ``"POST /login"`` hem de ``"401"`` ifadelerinin aynı satırda geçmesini istiyoruz. Bunu ardışık boru hattı (`|` - pipe) kullanarak yapabiliriz:
```Bash
grep "POST /login" /var/log/nginx/access.log | grep "401"
```
Bu komut ne yapıyor?

İlk ``grep`` dosyayı okur ve sadece içinde ``"POST /login"`` geçen satırları ayıklar.

Araya koyduğumuz | işareti, bu ayıklanan satırları ikinci ``grep`` komutuna aktarır.

İkinci ``grep`` ise o gelen satırların içinden sadece ``"401"`` hatası barındıranları seçip ekrana basar. Böylece nokta atışı saldırganları görürsün.



#### 2. Adım: Canlı Akan Logu Takip Etmek (``tail -f``)

"Log dosyası saniyede yüzlerce satır akıyor ve ben en güncel logları canlı görmek istiyorum" diyorsan, ``less`` yerine ``tail`` komutunu kullanmalısın.

```Bash
tail -n 50 -f /var/log/nginx/access.log
```

Bu parametreler ne işe yarıyor?

``-n 50``: Dosyanın en sonundaki (kuyruğundaki) 50 satırı ekrana basar.

`-f` (follow): Terminali kapatmaz, dosyayı açık tutar. Sunucuya yeni bir log satırı düştüğü anda canlı olarak terminal ekranında aşağıya doğru kaymaya başlar. Saldırının o an devam edip etmediğini böyle anlarsın.



#### 3. Adım: En Çok Saldıran IP'leri Sıralamak (İleri Düzey Awk & Sort Zinciri)

İşte mülakatların vazgeçilmez, gerçek hayatın ise en çok can kurtaran komut zinciri. Adım adım inşa edelim:
```Bash
awk '{print $1}' /var/log/nginx/access.log | sort | uniq -c | sort -nr | head -n 10
```

Bu sihirli zincir nasıl çalışıyor?

``awk '{print $1}'``: Log satırındaki boşluklara bakar ve sadece 1. sütunu (yani IP adresini) çekip alır, gerisini çöpe atar.

``sort``: Alınan tüm IP adreslerini alt alta alfabetik/sayısal olarak sıralar. (Bir sonraki komutun çalışması için bu şarttır).

``uniq -c``: Alt alta gelen aynı IP adreslerini teke düşürür ve soluna kaç kere tekrar ettiğini yazar. (Örn: ``4500 192.168.1.150``).

``sort -nr``: Sol tarafa yazılan bu sayıları, numaraya göre (`-r` - reverse) yani en büyükten en küçüğe doğru yeniden sıralar.

``head -n 10``: Bize en çok istek atan ilk 10 IP adresini gösterir.

Bu komutun çıktısına baktığında en üstte 150000 91.93.x.x görüyorsan, o IP adresini doğrudan firewall üzerinden engelleyerek (Drop) sunucuyu rahatlatırsın.





## 21. Gün: Bellek Canavarlarini Yakalamak

Karşimizda yine çok popüler bir Senior SysAdmin krizi var. Veri tabaninin durup dururken kapanmasi kurumsal dünyada kirmizi alarmdir.
Senden İstenen Adimlar:

##### 1. Linux'ta fiziksel RAM ve Swap alani tamamen tükendiğinde, işletim sisteminin kilitlenmesini önlemek için en çok RAM tüketen büyük süreçleri acimasizca seçip öldüren bu yerleşik Kernel mekanizmasinin adi nedir?

##### 2. Bu mekanizmanin PostgreSQL'i gerçekten öldürüp öldürmediğini kanitlamak için, doğrudan çekirdeğin (Kernel) loglarini barindiran dmesg komutunu hangi kelimeyle filtreleyerek ararsin? (Loglarda neyi avlamamiz gerekir?)

##### 3. Bu tarz bir krizin gelecekte tekrar yaşanmasini önlemek adina, Linux Kernel'inin "RAM sikiştiğinda ne kadar kolay/agresif bir şekilde Swap alanina geçiş yapacağini" belirleyen o meşhur swappiness değeri varsayilan olarak kaç gelir ve kurumsal veri tabani sunucularinda (PostgreSQL/Oracle/MSSQL) performans için kaça düşürülmesi önerilir?



Gelin bu kurumsal dünyada çok can yakan OOM Killer konusunu ve veri tabani sunucularinin can damari olan Swappiness ayarini derinlemesine inceleyelim.

##### 1. Adim: Acimasiz İnfazci: OOM Killer (Out of Memory Killer)

Söylediğin killall komutu, biz yöneticilerin terminalden elle çaliştirdiği, "X ismindeki tüm süreçleri kapat" dediğimiz bir araçtir.

Soruda bahsettiğim, RAM bittiğinde sistem kilitlenmesin diye Kernel'in otomatik devreye aldiği mekanizmanin adi OOM Killer (Out of Memory Killer)'dir.

Nasil Çalişir? Sistemde RAM ve Swap tamamen bitince Kernel panikler. Eğer hiçbir şeyi kapatmazsa tüm işletim sistemi donacaktir. OOM Killer hemen devreye girer, süreçlerin RAM tüketimlerine ve çalişma sürelerine bakarak bir "kötülük puani" (OOM Score) hesaplar. Sunucuda en çok RAM'i genellikle veri tabani (PostgreSQL) tükettiği için, OOM Killer gider ve en büyük süreç olan PostgreSQL'i sistem yaşasin diye acimasizca vurur.

##### 2. Adim: Suçüstü Yakalamak (Puan: 8/10)

dmesg | grep postgresql komutu sana PostgreSQL ile ilgili Kernel loglarini getirir, çok mantikli. Ancak bazen loglarda sadece servisin öldüğü yazar, onu kimin öldürdüğü net çikmaz.

OOM Killer'in tetiği çektiğini kesin olarak kanitlamak ve adli bilişim (forensics) raporu hazirlamak için doğrudan mekanizmanin kendi adini aratiriz:

```bash
sudo dmesg | grep -i -E 'oom|killed process'
## veya daha genel loglardan bakmak için:
sudo grep -i 'killed process' /var/log/syslog
``` 

Bu komutun çiktisinda tam olarak şu satiri yakalarsin:
Out of memory: Killed process 4523 (postgres) total-vm:16384kB, anon-rss:8192kB, file-rss:0kB, shmem-rss:0kB
Bu satiri gördüğün an yazilimcilara veya yönetime sunum yapabilirsin: "Sorun yazilimsal değil, sunucunun RAM'i yetersiz geldiği için işletim sistemi servisi korumak amaciyla kapatmiş."


##### 3. Adim: Swappiness Ayari (Yeni Bilgi 🚀)

Swappiness, Linux Kernel'inin fiziksel RAM'deki verileri diskteki Swap alanina taşimak için ne kadar istekli olduğunu belirleyen 0 ile 100 arasinda bir değerdir.

Varsayilan Değer: Birçok Linux dağitiminda (Ubuntu, CentOS) varsayilan olarak 60 gelir. Bu, "RAM %40 civarina geldiğinde yavaş yavaş Swap kullanmaya başla" demektir.

Kurumsal Veri Tabani Standardi: PostgreSQL, Oracle veya MS SQL gibi yüksek performansli veri tabani sunucularinda disk operasyonlari çok yoğundur. Eğer Kernel erkenden Swap kullanmaya kalkarsa veri tabani ciddi şekilde yavaşlar. Bu yüzden kurumsal dünyada veri tabani sunucularinda swappiness değeri 10 veya 1 seviyesine düşürülür!

Bu ayari nasil kontrol eder ve kalici değiştiririz?

```bash
## Anlik swappiness değerini görmek için:
cat /proc/sys/vm/swappiness

## Geçici olarak 10'a düşürmek için:
sudo sysctl vm.swappiness=10

## Sunucu reboot olduğunda da kalici olmasi için:
## /etc/sysctl.conf dosyasinin en altina şu satir eklenir:
vm.swappiness = 10
```



## 22. Gün: Disk Bölümleme ve Dosya Sistemi Oluşturma (Fdisk, Gparted ve Mkfs)

LVM konusunu ilk gün konuşmuştuk. Şimdi LVM olmadan, sisteme yeni eklenen yalin bir diski sifirdan bölümlere ayirip (partitioning) formatlamayi öğreneceğiz.
22. Gün Senaryosu: "Sifir Kilometre Disk Yapilandirmasi"

Şirketteki yedekleme sunucusuna fiziksel olarak 1 TB boyutunda yeni bir SSD disk takildi. Sistem bu diski /dev/sdc olarak gördü. Bu disk şu an tamamen ham (raw) durumda; içinde ne bir bölüm var ne de bir dosya sistemi.

Senden istenen bu diski tek bir parça halinde bölümlendirip, kurumsal Linux standardi olan EXT4 dosya sistemiyle formatlaman ve kullanima hazir hale getirmen.

Senden İstenen Adimlar:

##### 1. Bu tamamen ham durumdaki /dev/sdc diskinin içerisine girip yeni bir bölüm (partition) oluşturmak için kullandiğimiz o geleneksel terminal araci nedir?

##### 2. Bölümleme bitti ve artik elinde /dev/sdc1 var. Bu birimi EXT4 formatinda biçimlendirmek (formatlamak) için hangi komutu kullanirsin?

##### 3. Her şey bitti. Bu yeni diski /etc/fstab dosyasina güvenle eklemek için disklerin o benzersiz kimlik numarasini (UUID) öğrenmemiz gerekir. Bir diskin veya bölümün UUID değerini ekrana basan o pratik komut hangisidir?



##### 1. Adim: Bölümleme (Partitioning) (Puan: 9/10)

fdisk kesinlikle doğru araç. Terminalde şu komutla diskin içine girersin:
```Bash
sudo fdisk /dev/sdc
```

İçeride interaktif bir menü karşilar seni. Sirasiyla ``n`` (new partition), ``p`` (primary), 1 (bölüm numarasi) tuşlarina basip varsayilan değerleri onaylayarak diski tek parça halinde bölersin. En son ``w`` (write) diyerek değişiklikleri diske yazip çikarsin. Artik elinde ```/dev/sdc1``` vardir.

(Daha büyük, örneğin 2 TB'tan büyük modern diskler için ```fdisk``` yerine ```parted``` veya ```gdisk``` araçlari kullanilarak GPT bölüm tablosu oluşturulmasi kurumsal standarttir).

##### 2. Adim: Biçimlendirme (Formatting) (Puan: 10/10)

mkfs (Make File System) tam olarak aradiğimiz komut ailesi. sdc1 bölümünü EXT4 yapmak için komut tam olarak şöyledir:
```Bash
sudo mkfs.ext4 /dev/sdc1
## veya alternatif olarak:
sudo mkfs -t ext4 /dev/sdc1
```

Bu komut saniyeler içinde dosya sistemini inşa eder ve diski yazilabilir hale getirir.


##### 3. Adim: UUID Öğrenme Sihirbazi: blkid (Yeni Bilgi 🚀)

Linux'ta diskler bazen reboot sonrasinda harf değiştirebilir (Örn: ```/dev/sdc``` olan disk bir sonraki açilişta ```/dev/sdd``` olabilir). Bu durum ```/etc/fstab``` dosyasinda çökmelere yol açar. Bu yüzden diskleri harfiyle değil, fabrikasyon benzersiz kimliği olan UUID (Universally Unique Identifier) ile fstab'a ekleriz.

Sistemdeki tüm disklerin ve bölümlerin UUID numaralarini jilet gibi ekrana basan o meşhur komut blkid (Block ID) komutudur:
```Bash
sudo blkid /dev/sdc1
```
Bu komutun çiktisi tam olarak şuna benzer:
```/dev/sdc1: UUID="a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d" BLOCK_SIZE="4069" TYPE="ext4"```

Buradaki tirnak içindeki uzun kodu kopyalayip ```/etc/fstab``` içerisine şu şekilde yazariz ve sunucu artik disk harfleri değişse bile asla boot sirasinda takilmaz:
```sh
UUID=a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d  /backup  ext4  defaults  0  2
```



## 23. Gün: Linux Performans Analizi ve Darboğaz Tespiti (Load Average & Uptime)

Temel disk yönetimini de tamamladik. Şimdi bir Linux sunucusunun genel sağlik durumunu tek bir bakişta okuma sanatina geçiyoruz.
23. Gün Senaryosu: "Sunucu Ağliyor Ama Neden?"

Müşteriler sistemde genel bir yavaşliktan şikayetçi. Sunucuya SSH attin ve terminale girdin. Sunucunun donanimsal bir darboğaza (bottleneck) girip girmediğini anlamak için ilk olarak ``uptime`` komutunu çaliştirdin.

Ekrana şu çikti düştü:
```17:00:21 up 45 days, 3:12,  2 users,  load average: 12.50, 8.10, 3.05```

Sunucunun 4 adet CPU çekirdeğine (4 Cores) sahip olduğunu biliyorsun.
Senden İstenen Adimlar:

##### 1. Çiktinin en sonundaki ``load average`` (Yük Ortalamasi) kisminda yan yana duran bu üç farkli sayi (```12.50, 8.10, 3.05```) sirasiyla hangi zaman dilimlerindeki (kaç dakikalik) yük ortalamasini temsil eder?

##### 2. Sunucuda 4 CPU çekirdeği olduğunu varsaydiğimizda, son 1 dakikalik yük ortalamasinin 12.50 çikmasi kurumsal anlamda neyi ifade eder? Sunucu rahat midir, sinirda midir, yoksa aşiri yük altinda ezilmekte midir? (Mantiğini açiklamani bekliyorum).

##### 3. Bu yüksek yükün kaynağinin CPU mu, RAM mi yoksa Disk G/Ç (I/O Wait) mi olduğunu anlamak için virtual memory istatistiklerini canli veren hangi pratik komuttan yararlanirsin? (İpucu: ``vm...`` ile başlar).


#### 1. Adim: Load Average Zaman Dilimleri (Yeni Bilgi 🚀)

``uptime`` veya ``top`` komutunun sağ üst köşesinde gördüğün o üç sayi, sirasiyla sistemin son 1 dakikalik, son 5 dakikalik ve son 15 dakikalik yük ortalamasini gösterir.

`12.50` -> Son 1 dakikadaki durum

`8.10`  -> Son 5 dakikadaki durum

`3.05`  -> Son 15 dakikadaki durum

Buradaki artiş trendine bakarak (3'ten 8'e, oradan 12'ye çikmiş) krizin yeni büyümekte olan bir çiğ gibi sunucunun üzerine geldiğini anlayabilirsin.

#### 2. Adim: Load Average Mantiği ve CPU Çekirdek İlişkisi (Doğru Bilgi 🚀)

Linux'ta Load Average, yüzdeyi değil "işlem kuyruğunda bekleyen süreçlerin sayisini" ifade eder. Bunu bir otoban veya banka kuyruğu gibi düşünebilirsin.

Sunucumuzda 4 CPU çekirdeği var. Bu, sistemin ayni anda tam performansla 4 adet işi hiç bekleme yapmadan işleyebileceği anlamina gelir.

Yük = 4.00 olsaydi: 4 çekirdeğin 4'ü de ucu ucuna tam kapasite çalişiyor, kuyrukta bekleyen kimse yok demektir (İdeal sinir).

Yük = 12.50 ise: 4 çekirdek haril haril çalişiyor, ancak işlemciye yetişemeyen 8.5 adet işlem daha sirada, kuyrukta çaresizce bekliyor demektir!

Sonuç: Sunucu rahat değil, tam aksine kapasitesinin 3 katindan fazla yük altinda ezilmektedir. Terminalin sana yavaş tepki vermesinin, web sitesinin yavaşlamasinin sebebi işlemcinin bu kuyruğu eritememesidir.

3. Adim: Darboğazin Kaynağini Bulan Sihirbaz: ``vmstat`` (Yeni Bilgi 🚀)

Yükün 12.50 olduğunu gördük. Peki bu yükü işlemci mi yaratiyor, RAM yetersizliği mi yoksa disk yavaşliği mi? Bunu anlamak için ``vmstat`` (Virtual Memory Statistics) komutunu kullaniriz.

Terminalde şu şekilde çaliştirilmasi kurumsal bir alişkanliktir:
```Bash
vmstat 1 5
```
(Bu komut, 1 saniye araliklarla toplam 5 kere sistem istatistiklerini ekrana basar).

Çiktida bakman gereken iki kritik kolon vardir:

`r` (Running) kolonu: İşlemcide koşan veya sira bekleyen süreç sayisidir. Eğer burasi yüksekse sorun CPU kaynaklidir.

`b` (Blocked) kolonu: Diskten veri gelmesini beklediği için kilitlenen (I/O Wait) süreç sayisidir. Eğer burasi yüksekse disk hizin (Storage) sunucuya yetişemiyordur, yani sorun Disk kaynaklidir.




## 24. Gün: Güvenli Dosya İndirme ve Web İstekleri

Sistem performansını okumayı da cebe koyduk. Şimdi kurumsal ağlarda, sunuculara internetten dosya indirirken veya bir web servisine (API) terminalden istek atarken kullandığımız araçlara geçiyoruz.
24. Gün Senaryosu: "Terminalden API Testi ve Dosya İndirme"

Şirketteki yazılımcılar bir mikroservis geliştirdi. Bu servisin dışarıya açık bir adresi var: http://api.internal/v1/status.
Senden istenen, bu adrese terminalden bir HTTP isteği atıp dönen cevabı kontrol etmen. Ayrıca sunucuya internetten büyük bir kurulum dosyası (agent.tar.gz) indirmen gerekiyor ama şirketin interneti dalgalı olduğu için indirme yarıda kalırsa kaldığı yerden devam edebilmeli.
Senden İstenen Adımlar:

#### 1. http://api.internal/v1/status adresine terminalden hızlıca bir HTTP GET isteği atmak ve dönen ham metni (JSON/HTML) ekranda görmek için hangi popüler aracı kullanırsın?

#### 2. http://dosya.internal/agent.tar.gz adresindeki büyük dosyayı sunucuya indirirken, bağlantı koparsa kaldığı yerden devam etmesini (resume) sağlayan o meşhur indirme komutu ve parametresi hangisidir? (Kopyasız, ipucusuz!)



#### 1. Adım: Terminalden API Testi (``curl``) (Puan: 10/10)

``http://api.internal/v1/status`` gibi bir API ucunu (endpoint) test etmek, HTTP header bilgilerini incelemek veya JSON çıktılarını terminale basmak için en doğru tercih ``curl`` komutudur.

```Bash
curl http://api.internal/v1/status
```

Kurumsal SysAdmin Bonusu: Eğer sadece web sitesinin çalışıp çalışmadığını, yani arka planda dönen HTTP durum kodunu (200 OK, 404 Not Found vb.) sunucuyu yormadan, tüm sayfayı indirmeden görmek istersen şu parametreleri ekleriz:
    
```Bash
curl -I http://api.internal/v1/status
```
(`-I` parametresi sadece "Header" yani başlık bilgilerini getirir).



2. Adım: Kaldığı Yerden Devam Eden İndirme (``wget``) (Puan: 10/10)

Büyük dosyaları internetten veya intranet üzerinden sunucuya çekerken ``wget`` biçilmiş kaftandır. Şirketin interneti koptuğunda dosya indirme işleminin kaldığı yerden devam etmesini (resume) sağlayan o kritik parametre `-c` (continue) parametresidir.
```Bash
wget -c http://dosya.internal/agent.tar.gz
```
Nasıl Çalışır?
Diyelim ki 2 GB'lık dosyanın 1 GB'ı indi ve internet koptu. İnternet geri geldiğinde yukarıdaki komutu tekrar çalıştırırsan, ``wget`` diskteki mevcut 1 GB'lık dosyayı görür, karşı sunucuya "Ben ilk 1 GB'ı aldım, sen bana 1.01. GB'tan sonrasını gönder" der ve kaldığı yerden devam eder. Sıfırdan başlamayarak ciddi zaman kazandırır.







25. Gün: Linux Çekirdek Parametreleri ve Anlık Değişiklikler (Sysctl & Kernel Parameters)

günde seninle ``swappiness`` ayarını konuşurken ``/etc/sysctl.conf`` dosyasına ufak bir dokunuş yapmıştık. Bugün Linux Kernel'ının canlı çalışan ayarlarına doğrudan müdahale etmeyi öğreneceğiz.

25. Gün Senaryosu: "Ağ Trafiği Limite Takıldı! (Network Hardening)"

Şirketin çok yoğun istek alan web sunucusunda network performans sorunları yaşanıyor. İşletim sistemi gelen binlerce eşzamanlı (concurrent) bağlantıyı kuyrukta tutamayıp paketleri düşürüyor (drop ediyor). Senior Network ekibi sana geldi ve şu talimatı verdi:

"Sunucunun Kernel seviyesindeki maksimum bağlantı kuyruk limitini (``net.core.somaxconn``) acilen 1024'ten 65535'e yükseltmen gerekiyor. Ama sunucuyu kesinlikle reboot edemezsin, canlı sistem kesintiye uğramamalı!"
Senden İstenen Adımlar:

#### 1. Sunucuyu yeniden başlatmadan (canlı ortamda) bir Kernel parametresini anlık olarak değiştirmek ve devreye almak için hangi Linux komutunu ve parametresini kullanırsın?

#### 2. Yapılandırmanın sunucu gelecekte herhangi bir sebeple reboot olduğunda sıfırlanmaması ve kalıcı olması için bu net.core.somaxconn = 65535 satırını hangi kritik sistem dosyasına yazmalısın?

#### 3. Bu dosyaya yeni kurallar ekledikten sonra, sunucuyu reboot etmeden dosyadaki tüm yeni kuralları sisteme yeniden okutup (reload) aktif hale getirmek için hangi komutu çalıştırırsın?



#### 1. Adım: Canlı Sistemde Kernel Ayarı Değiştirmek (Yeni Bilgi 🚀)

Linux'ta canlı çalışan çekeceğe (Kernel) sunucuyu kapatıp açmadan anlık olarak parametre göndermek için ``sysctl`` komutunu kullanırız.

Network ekibinin bizden istediği değişikliği canlı sistemde kesintisiz uygulamak için komut şudur:
```Bash
sudo sysctl -w net.core.somaxconn=65535
```
`-w` (write) parametresi: Kernel'a "Sana yeni bir değer yazıyorum, bunu hafızanda anında güncelle" talimatı verir. Komutu çalıştırdığın milisaniyede sunucunun ağ kuyruk limiti yükselir ve paket düşmeleri (drop) bıçak gibi kesilir.





#### 2. Adım: Değişikliği Kalıcı Hale Getirmek (Puan: 10/10 - Geçmiş Bilgi Refleksi!)

günde ``swappiness`` ayarını yaparken kullandığımız o meşhur dosya burada da devreye giriyor. ``sysctl -w`` ile yaptığımız değişiklikler RAM üzerinde yaşar, yani sunucu reboot olursa silinir.

Kalıcı olması için satırı tam olarak şu dosyanın en altına ekleriz:

Dosya Yolu: ``/etc/sysctl.conf``

Dosyanın içine şu satırı yazar ve kaydederiz:

```bash
net.core.somaxconn = 65535
```

#### 3. Adım: Sunucuyu Reboot Etmeden Dosyayı Yeniden Okutmak (Yeni Bilgi 🚀)

``/etc/sysctl.conf`` dosyasına yeni kuralları yazdık. Sunucuyu yeniden başlatmadan, dosyadaki tüm yeni ayarları Kernel'a tek seferde yüklemek (reload etmek) için şu sihirli parametreyi kullanırız:
```Bash
sudo sysctl -p
```

`-p` (load policy/file) parametresi: Gider ``/etc/sysctl.conf`` dosyasını baştan aşağıya okur ve içeride gördüğü tüm kuralları canlı sisteme tek hamlede uygular. Kurumsal dünyada bir değişiklik yaptıktan sonra sunucuyu reboot etmek yerine hep ``sysctl -p`` tercih edilir.




## 26. Gün: Linux Dosya Arşivleme ve Sıkıştırma Standartları (Tar, Gzip ve Bzip2)

Kernel ayarlarını da cebe koyduk. Şimdi kurumsal dünyada logları saklarken, yedek alırken veya diskte yer açmaya çalışırken her gün istisnasız kullandığımız dosya paketleme operasyonlarına geliyoruz.
26. Gün Senaryosu: "Yedekleri Sıkıştırıp Arşivleyin"

Geliştiricilerin üzerinde çalıştığı ``/data/project_files`` dizini altında yaklaşık 50 GB veri var. Senden istenen, bu klasörü hem tek bir arşiv dosyası haline getirmen (tar formatı) hem de diskte az yer kaplaması için sıkıştırman (gzip formatı).

Oluşacak yedek dosyasının adının ``project_backup.tar.gz`` olması isteniyor.
Senden İstenen Adımlar:

#### 1. Bu klasörü tek bir komutla hem arşivleyip (tar) hem de gzip ile sıkıştırarak ``project_backup.tar.gz`` dosyasını oluşturacak o meşhur tar komutunu ve kurumsal parametre birleşimini (``-c...``) nasıl yazarsın?

#### 2. Oluşturduğun bu ``.tar.gz`` uzantılı arşiv dosyasının içini, dosyayı dışarıya hiç çıkarmadan (extract etmeden), sadece içindeki klasör yapısını ve dosya listesini terminalde görmek için ``tar`` komutuna hangi parametreyi vermelisin?

#### 3. Aradan zaman geçti ve bu yedeği geri açman (klasöre çıkartman) gerekti. Bu sıkıştırılmış arşiv dosyasını bulunduğun dizine geri açmak için hangi ``tar`` parametre birleşimini kullanırsın?


#### 1. Adım: Sıkıştırılmış Arşiv Oluşturmak (Yeni Bilgi 🚀)

Linux'ta klasörleri doğrudan sıkıştıramazsınız. Önce klasördeki tüm dosyaları tek bir paket haline (arşiv) getirmek, ardından bu paketi sıkıştırmak gerekir. ``tar`` komutu bu iki işlemi tek seferde yapar.

50 GB'lık ``/data/project_files`` dizinini sıkıştırıp ``project_backup.tar.gz`` yapmak için komutumuz:
```Bash
tar -czvf project_backup.tar.gz /data/project_files
```
Bu parametrelerin gizemi nedir? (Hafızaya Kazınacak Kısım):

`-c` (create): Yeni bir arşiv dosyası oluştur.

`-z` (gzip): Bu arşivi Gzip algoritmasıyla sıkıştır (böylece dosya boyutu ciddi oranda düşer ve sonuna ``.tar.gz`` eklenir).

`-v` (verbose): Sıkıştırılan dosyaları ekranda canlı canlı listele (işlemin donmadığını görmek için harikadır).

`-f` (file): Oluşacak arşiv dosyasının adını belirteceğimizi söyler (parametrelerin en sonuna yazılır ve hemen ardından dosya adı gelir).



#### 2. Adım: Arşivi Açmadan İçine Bakmak (Yeni Bilgi 🚀)

Bazen elimize çok büyük bir yedek dosyası geçer ve diskte yer kaplamasın diye dosyayı dışarı çıkarmadan sadece içinde hangi dosyaların olduğunu görmek isteriz.

Bunun için tek yapmamız gereken `-c` (create) parametresini `-t` (list) ile değiştirmektir:
```Bash
tar -tzf project_backup.tar.gz
```
Bu komut, sıkıştırılmış paketi hiç açmadan içindeki tüm klasör ve dosya ağacını jilet gibi ekrana listeler.
3. Adım: Arşivi Dışarı Çıkarmak (Extract) (Yeni Bilgi 🚀)

Günün birinde bu yedeği geri yüklemen gerektiğinde, paketi bulunduğun klasöre açmak için bu sefer -x (extract) parametresini kullanırız:
```Bash
tar -xzvf project_backup.tar.gz
```
`-x`: Arşivi dışarı çıkar/çöz.

Eğer bu yedeği bulunduğun dizine değil de başka bir klasöre (örneğin ``/tmp``) çıkartmak istersen, komutun sonuna büyük `-C` (Change directory) parametresini eklersin:
```tar -xzvf project_backup.tar.gz -C /tmp```

## 27. Gün: Disk Alanı Analizi ve Görsel Temizlik (Du, Df ve Ncdu)

Arşivleme ve sıkıştırmayı da cebe koyduk. Şimdi, sunucuda disk dolduğunda "hangi klasörün ne kadar yer kapladığını" bulup nokta atışı temizlik yapma günümüz.
27. Gün Senaryosu: "Diski Kim Şişiriyor?"

İzleme (monitoring) sisteminden yine disk doluluk uyarısı aldın. Sunucuya bağlandın. Amacın, kök dizinden (`/`) başlayarak hangi klasörün diskte ne kadar Gigabyte yer kapladığını bulmak ve en çok yer kaplayan klasörün içine sızıp gereksiz verileri temizlemek.
Senden İstenen Adımlar:

#### 1. Bulunduğun dizindeki tüm klasörlerin boyutlarını, insanların okuyabileceği formatta (MB/GB cinsinden) ve derinlere inmeden sadece ana başlıklar halinde görmek için hangi ``du`` (disk usage) komut mimarisini kullanırsın?

#### 2. Standart ``du`` komutu terminalde çok karmaşık çıktılar verebilir. Kurumsal Linux yöneticilerinin bu tarz disk analizlerini interaktif, yön tuşlarıyla klasörlerin içine girip çıkarak ve dosya boyutlarını grafik barlarla görerek yapmasını sağlayan, NCurses tabanlı o efsane görsel disk analiz aracı hangisidir?

#### 3. Linux'ta genel disk doluluk oranını veren ``df -h`` komutu ile klasör bazlı boyut veren ``du -sh`` komutu arasındaki temel fark nedir? Hangisi bize sistemdeki disk bölümlerini (partition) gösterir?




#### 1. Adım: Klasör Boyutlarını Listelemek (du) (Puan: 10/10)

``du -sh /`` komutu kesinlikle doğru!

`-s` (summary): Klasörün altındaki binlerce dosyayı tek tek listelemek yerine, o klasörün toplam boyutunu tek bir satırda özetler.

`-h` (human-readable): Boyutu kilobayt cinsinden değil, bizim anlayacağımız şekilde `15G`, `450M` şeklinde gösterir.

Kurumsal İpucu: Eğer sadece `/` (kök) dizininin altındaki birinci seviye klasörlerin (örn: ``/var``, ``/usr``, ``/home``) boyutlarını toplu halde görmek istersen şu komut hayat kurtarır:
```Bash
sudo du -h --max-depth=1 /
```

#### 2. Adım: Terminalin Disk Röntgeni: ``ncdu`` (Yeni Bilgi 🚀)

Standart ``du`` komutuyla uğraşmak, klasör klasör gezip elle boyut bakmak kurumsal sistemlerde çok zaman kaybettirir. İşte bu yüzden her Linux yöneticisinin sunucuya ayak basar basmaz ilk kurduğu araç ``ncdu`` (NCurses Disk Usage) aracıdır.
```Bash
sudo apt install ncdu  # Ubuntu/Debian için
sudo ncdu /
```
Neden bir efsanedir?

* Sana tamamen interaktif bir arayüz açar.

* Klasörleri en çok yer kaplayandan en aza doğru otomatik sıralar.

* Klavyenin yön tuşlarıyla klasörlerin içine girip çıkabilir, hangi alt klasörün diski şişirdiğini saniyeler içinde bulabilirsin.

* Silmek istediğin gereksiz bir dosyanın üzerine gelip sadece `d` (delete) tuşuna basarak anında temizlik yapabilirsin.



#### 3. Adım: ``df`` ve ``du`` Arasındaki Fark (Puan: 10/10)

Yazdığın gibi; ``df -h`` (disk free) doğrudan disk bölümlerini (partition), bağlı olan cihazları (SATA, NVMe, NFS) ve bunların doluluk oranlarını gösterir. ``du -sh`` (disk usage) ise dosya ve klasör bazlı derinlemesine tüketimi gösterir.

Çok Kritik Bir Senior Detayı (Mülakat Sorusu):
Bazen ``df -h`` komutu diskin %100 dolu olduğunu söyler ama `/` dizininde ``du -sh`` çalıştırdığında dosyaların toplam boyutu sadece 20 GB görünür (arada kayıp 80 GB vardır).

* Nedeni: Bir süreç (proses) büyük bir log dosyasını açık tutuyorken, sen gidip o dosyayı ``rm`` ile silersen dosya diskten tam olarak silinmez. Süreç onu hafızada tuttuğu için df diski dolu gösterir ama ``du`` dosyayı bulamaz. Çözümü, o süreci yeniden başlatmaktır (``systemctl restart``)





































