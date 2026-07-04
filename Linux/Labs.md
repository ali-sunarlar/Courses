# 1. Gün Senaryosu: "Disk Doldu ve Servis Çöktü!"

Bir şirkette Linux Administrator olarak çalışıyorsun. Gece yarısı izleme (monitoring) sisteminden kritik bir alarm aldın: Üretim (Production) ortamındaki bir Ubuntu veri tabanı sunucusunda disk alanı %100 dolmuş ve PostgreSQL servisi durmuş.

Sunucuya SSH ile bağlandın ve durum şu:

Sunucuda LVM (Logical Volume Manager) yapısı kullanılıyor.

/dev/mapper/vg_prod-lv_data adındaki mantıksal birim (Logical Volume) /var/lib/postgresql dizinine bağlı ve tamamen dolu.

Altyapı ekibi sunucuya sanallaştırma ortamından (VMware/Proxmox vb.) fiziksel olarak 20 GB ek boş disk tanımladı (/dev/sdb olarak sisteme eklendi).

Senden İstenen Adımlar:

Sistemi veri kaybı olmadan ve en kısa sürede ayağa kaldırman gerekiyor. Bana şu adımları hangi komutlarla ve hangi sıra ile yapacağını açıkla:

## 1. Yeni eklenen /dev/sdb diskinin sistem tarafından işletim sistemi yeniden başlatılmadan (reboot edilmeden) tanınıp tanınmadığını nasıl kontrol edersin?

## 2. Bu yeni /dev/sdb diskini mevcut LVM yapısına dahil ederek /dev/vg_prod/lv_data birimini 20 GB nasıl genişletirsin? (Sırasıyla PV, VG ve LV adımlarını yazmalısın).

## 3. Disk alanını genişlettikten sonra, dosya sisteminin (örneğin ext4 veya xfs olduğunu varsayarak) bu yeni alanı tanıması için ne yapmalısın?

Son olarak, çöken veri tabanı servisini kontrol edip tekrar başlatmak için hangi komutları kullanırsın?


## 1. Adım: Diski Reboot Etmeden Tanıtmak (Puan: 9/10)

echo 1 > /sys/block/sdb/device/rescan komutu harika bir yöntem. Ancak senaryoda diskin sisteme yeni eklendiğini (/dev/sdb adıyla yeni bir aygıt olarak) belirtmiştik. Eğer disk sistemde daha önce hiç yoksa, işletim sisteminin SCSI veri yolunu (bus) tarayarak bu yeni aygıtı keşfetmesini sağlamak daha garanti bir yoldur:

```bash
# Tüm SCSI host'ları tarayarak yeni diskleri bulmak için:
echo "- - -" > /sys/class/scsi_host/host0/scan
# (Sistemdeki host0, host1 gibi tüm hostlar için veya kısa bir script ile hepsi için yapılır)

# Ardından diskin gelip gelmediğini doğrulamak için:
lsblk veya fdisk -l
```

## 2. Adım: LVM Genişletme (Puan: 5/10) - Buraya Dikkat!

Burada kritik bir mantık hatası var. Yazdığın komut: pvresize /dev/sdb.

Hata neden önemli? pvresize, halihazırda LVM içinde olan (Physical Volume yapılmış) bir diskin boyutu büyüdüğünde kullanılır. Ancak /dev/sdb sisteme yeni eklenen, tamamen yabancı bir disk.

Doğru sıranın şu şekilde olması gerekirdi:

Yeni diski LVM formatına hazırla (Physical Volume oluştur):

```bash
pvcreate /dev/sdb
``` 

Bu yeni PV'yi mevcut Volume Group'a (vg_prod) ekle (Genişlet):

```bash
vgextend vg_prod /dev/sdb
```

Şimdi Logical Volume'u genişlet (Senin yazdığın komut tam olarak doğru!):

```bash
lvextend -l +100%FREE /dev/mapper/vg_prod-lv_data
``` 


## 3. Adım: Dosya Sistemini Büyütmek (Puan: 10/10)

Burası kusursuz. xfs_growfs ve resize2fs ayrımlarını tam olarak doğru yaptın.
Küçük bir SysAdmin ipucu: lvextend komutunun sonuna -r (veya --resizefs) parametresini eklersen, LVM genişleme biter bitmez dosya sistemini (ext4 veya xfs fark etmeksizin) arka planda otomatik olarak büyütür. Tek komutla iki işi halletmiş olursun:

```bash
lvextend -l +100%FREE -r /dev/mapper/vg_prod-lv_data
```

## 4. Adım: Servis Kontrolü ve Log Analizi (Puan: 10/10)

systemctl status ile durumu kontrol etmek ve loglara bakmak en doğru pratik. journalctl -u postgresql veya postgresql'in kendi log dizinine (/var/log/postgresql/) bakarak disk doluluğundan dolayı veri tabanında bir bozulma (corruption) olup olmadığını incelemen gerekir. Ardından 
```sh
systemctl start postgresql 
```
ile servisi ayağa kaldırabilirsin.


# 2. Gün: Kullanıcı Yönetimi, İzinler ve Güvenlik Sıkılaştırma (Hardening)

2. Gün Senaryosu: "Geliştirici Erişimi ve Yetki Sınırlandırması"

Şirkete yeni katılan kıdemli bir yazılımcı var. Adı: umut. Umut'un bu veri tabanı sunucusunda çalışması gerekiyor ancak sistemde tam yetkili (root) olmasını istemiyoruz.
Senden İstenen Adımlar:

## 1. umut adında bir kullanıcı oluştur. Bu kullanıcının varsayılan kabuğu (shell) bash olsun.

## 2. Umut'un sadece ve sadece systemctl restart postgresql ve systemctl status postgresql komutlarını sudo yetkisiyle (şifre girerek veya şifresiz) çalıştırmasına izin vermek istiyorsun. Diğer hiçbir sudo komutunu (örneğin sudo apt update veya sudo su) çalıştıramamalı. Bunu /etc/sudoers veya /etc/sudoers.d/ altında nasıl yapılandırırsın? (Satırı tam yazmanı bekliyorum).

## 3. Güvenlik denetiminde (audit), sistemdeki bazı kritik dosyaların izinleri inceleniyor. /etc/passwd ve /etc/shadow dosyalarının izinleri (permission) ve sahiplikleri (owner/group) normal şartlarda ne olmalıdır? Güvenli olup olmadıklarını hangi komutla kontrol edersin?



## 1. Adım: Kullanıcı Oluşturma (Puan: 10/10)

```useradd -m -s /bin/bash``` umut komutu kesinlikle doğru. -m ile home dizinini oluşturdun, -s ile de varsayılan shell'i belirledin.

## 2. Adım: Sudo Yetkilendirmesi (Puan: 9/10)

Yazdığın satır mantık olarak tamamen doğru:
```umut ALL=(ALL) NOPASSWD: /bin/systemctl restart postgresql, /bin/systemctl status postgresql```

Buradaki Küçük Güvenlik Riski (Senior Detayı):
systemctl status postgresql komutu çalıştırıldığında, eğer çıktı ekrana sığmayacak kadar uzunsa sistem otomatik olarak bunu less veya more gibi bir sayfalayıcı (pager) ile açar. less komutu sudo yetkisiyle çalıştığında, kullanıcı ! tuşuna basarak root kabuğuna (shell bypass) düşebilir!

Bunu engellemek için kurumsal dünyada sudoers satırına SYSTEMD_PAGER kısıtlaması eklenir veya sadece restart yetkisi verilir. Ayrıca bu kuralı doğrudan /etc/sudoers içine yazmak yerine, /etc/sudoers.d/umut adında ayrı bir dosya oluşturup içine yazmak en temiz yönetim şeklidir (Best Practice).


## 3. Adım: Dosya İzinleri ve Güvenlik Denetimi (Puan: 8/10)

ls -l ile kontrol etmek en temel ve doğru yöntem. Peki kurumsal bir denetimde (audit) karşına çıkması gereken ideal senaryo nedir?

/etc/passwd: Sistemdeki tüm kullanıcıların temel bilgilerini içerir. Herkesin okuyabilmesi gerekir ama sadece root yazabilmelidir.

İdeal İzin: 644 (-rw-r--r--)
Sahibi/Grubu: root:root

/etc/shadow: Kullanıcı şifrelerinin hash'lenmiş hallerini barındırır. Çok kritiktir. Sıradan kullanıcılar kesinlikle okuyamamalıdır.

İdeal İzin: 640 (-rw-r-----) veya bazı dağıtımlarda 600 (-rw-------)

Sahibi/Grubu: root:shadow (veya root:root)

Eğer denetimde bu dosyalardan birinin izni örneğin 777 veya 666 çıkarsa, o sunucu doğrudan kırmızı alarm verir.




# 3. Gün: Ağ Yönetimi ve Sorun Giderme (Networking & Troubleshooting)

Kullanıcı yönetimini de başarıyla tamamladık. Şimdi bir Linux yöneticisinin mesaisinin en az %30'unu kaplayan alana geliyoruz: Network sorunları.
3. Gün Senaryosu: "Uygulama Sunucusu Veri Tabanına Bağlanamıyor!"

Yazılım ekibi (umut ve arkadaşları) yeni bir mikroservis yayına aldı. Ancak uygulama loglarında sürekli şu hatayı alıyorlar: Connection timed out: database.internal:5432.

Uygulamanın çalıştığı Ubuntu Linux sunucusuna SSH ile bağlandın. Sorunun network katmanında mı, DNS'te mi yoksa karşı sunucuda mı olduğunu bulman gerekiyor.


Senden İstenen Adımlar:

## 1. İlk olarak, uygulama sunucusunun database.internal alan adının IP adresini doğru çözüp çözemediğini (DNS sorununu) hangi komutlarla kontrol edersin? (En az 2 alternatif komut).

## 2. DNS'in doğru IP'yi çözdüğünü varsayalım (Örn: 10.0.0.50). Ancak sorun devam ediyor. Karşı sunucunun 5432 portunun erişilebilir olup olmadığını, yani arada bir firewall (güvenlik duvarı) engeli veya port kapanması olup olmadığını ping komutu dışında hangi komutlarla test edersin?

## 3. Eğer sorun uzak sunucuda değil de, bizim kendi uygulama sunucumuzun üzerindeki yerel bir firewall'dan (ufw veya iptables) kaynaklanıyorsa, sunucudaki aktif firewall kurallarını listelemek ve durumunu görmek için hangi komutları kullanırsın?


## 1. Adım: DNS Sorun Giderme (Puan: 10/10)

Burada tam puan aldın, çünkü sadece komut söylemekle kalmadın, Linux'un isim çözümlleme (name resolution) mekanizmasının arka planına baktın.

Sıralama Mantığı: Linux bir domaini çözmek istediğinde önce ```/etc/nsswitch.conf``` dosyasına bakar. Burada genellikle files dns yazar. Yani sistem önce ```/etc/hosts``` (files) dosyasına, orada bulamazsa ```/etc/resolv.conf``` (dns) içindeki DNS sunucularına sorar. Bu sırayı kontrol etmen mükemmel.

Komut Alternatifleri: nslookup harika. Modern sistemlerde bunun yanına dig database.internal veya host database.internal komutlarını da ekleyebiliriz. dig komutu DNS sunucusundan dönen tüm detayları (TTL, Query Time vb.) verdiği için troubleshooting esnasında çok sevilir.

## 2. Adım: Port ve Erişilebilirlik Kontrolü (Puan: 8/10) - Küçük Bir Detay

telnet ve curl kullanımı networkçülerin vazgeçilmezidir. telnet database.internal 5432 komutu bağlantı durumunu net olarak gösterir.

Ancak ss komutunda bir hedef şaşırması var:

Senaryomuzda biz Uygulama Sunucusundayız ve uzak veri tabanı sunucusuna bağlanmaya çalışıyoruz.

Yazdığın ```ss -tulpn | grep 5432``` komutu, üzerinde bulunduğun sunucunun 5432 portunu dinleyip dinlemediğini (LISTEN) kontrol eder. Uygulama sunucusunda PostgreSQL kurulu olmadığı için bu komut boş dönecektir ve bu normaldir. Uzak sunucudaki portu yerelde ss ile göremeyiz.

Peki telnet dışında uzak portu taramak için ne kullanabilirdin?

En popüler ve güçlü araç nc (netcat) veya nmap olurdu:

```bash
nc -zv database.internal 5432
# veya
nmap -p 5432 database.internal
```

## 3. Adım: Yerel Firewall Kontrolü (Puan: 9/10)

"Yerel firewall açık mı değil mi kontrol ederim" dedin, çok doğru. Peki bunu hangi komutlarla yapardın? Kurumsal dünyada Ubuntu üzerinde varsayılan olarak UFW (Uncomplicated Firewall) veya arka planda iptables/nftables bulunur.

Kullanman gereken komutlar şunlar olmalıydı:

```bash
# UFW durumunu ve kurallarını görmek için:
sudo ufw status verbose

# Eğer ufw aktif değil ama iptables kuralları varsa:
sudo iptables -L -n -v
```

# 4. Gün Senaryosu: "Özel Script Logları Diski Şişiriyor"

Şirketteki DevOps ekibi, sunucuda arka planda sürekli çalışan ve log üreten özel bir Python uygulaması (script) çalıştırdı. Bu uygulama bir Systemd Servisi olarak yapılandırılmış.

Ancak uygulama loglarını standart journald yerine doğrudan /var/log/my_app.log dosyasına yazıyor. Uygulama çok canlı olduğu için bu log dosyası günde 5 GB büyüyor ve birkaç güne diski yine bitirecek!
Senden İstenen Adımlar:

## 1. Bu Python uygulamasının Systemd servis adının myapp.service olduğunu varsayalım. Bu servisin şu an çalışıp çalışmadığını, sistem başlangıcına (boot) eklenip eklenmediğini (enable/disable) nasıl kontrol edersin?

## 2. Bu /var/log/my_app.log dosyasının diski doldurmasını engellemek için Linux'un yerleşik logrotate mekanizmasını kullanmak istiyorsun. Logların günlük (daily) olarak döndürülmesini (rotate), eski logların sıkıştırılmasını (compress) ve sistemde en fazla 7 günlük log tutulmasını istiyorsun. /etc/logrotate.d/myapp adında bir dosya oluşturup içine yazman gereken konfigürasyonu bana taslak olarak gösterebilir misin?

## 3. logrotate konfigürasyonunu yazdıktan sonra, bir hata olup olmadığını görmek ve sistemi test etmek için bu kuralı elle (manually) ve zorla (force) nasıl çalıştırırsın?


## 1. Adım: Servis Durumu ve Boot Kontrolü (Puan: 10/10)

systemctl status myapp.service komutu tam olarak doğru. Çıktıda bahsettiğin loaded (...; enabled; ...) ibaresi servisinin boot sırasında otomatik başlayacağını gösterir.

Eğer disabled görseydin, bunu aktifleştirmek için şu komutu kullanacaktın:

```bash
sudo systemctl enable myapp.service
```

## 2. Adım: Logrotate Konfigürasyonu (Yeni Bilgi 🚀)

Linux'ta logların diski şişirmesini önlemek için logrotate servisi kullanılır. ```/etc/logrotate.d/``` dizini altına uygulaman için bir dosya açarsın ve kuralları yazarsın.

Senaryomuzdaki istekler şunlardı: Günlük dönsün, sıkıştırılsın ve en fazla 7 gün tutulsun.

```/etc/logrotate.d/myapp``` dosyasının içeriği tam olarak şöyle olmalıdır:

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

daily: Log döndürme işlemi her gün yapılsın.

rotate 7: Sistemde en fazla 7 eski log dosyası tutulsun (8. gün, en eski olan silinir).

compress: Eski loglar yer kaplamasın diye .gz formatında sıkıştırılsın.

missingok: Eğer log dosyası o gün henüz oluşmadıysa hata verme, sessizce geç.

notifempty: Eğer log dosyası boşsa (0 byte) boşuna döndürme işlemi yapma.

copytruncate: (En kritik SysAdmin numarası!) Python uygulaması log dosyasını sürekli açık tuttuğu için, dosyayı direkt silersek uygulama log yazmayı bırakabilir. Bu parametre, mevcut logun bir kopyasını alır ve orijinal dosyanın içini boşaltır (truncate). Uygulama kesintisiz yazmaya devam eder.


## 3. Adım: Logrotate Kuralını Elle ve Zorla Test Etmek (Yeni Bilgi 🚀)

Yazdığın bu kuralın çalışıp çalışmadığını gece yarısını beklemeden hemen test etmek istersin. Bunun için logrotate komutuna bazı parametreler veririz:


```bash
sudo logrotate -f /etc/logrotate.d/myapp
```

-f (or --force): Logrotate'e "Normalde zamanı gelmedi ama sen kuralları hiçe say ve bu logu şimdi, zorla döndür" talimatı verir.

Bu komuttan sonra /var/log/ dizinine gidip ls -l yaparsan, my_app.log.1.gz adında sıkıştırılmış ilk eski logunu görebilirsin.



# 5. Gün: Süreç Yönetimi ve Performans Analizi (Process Management & Troubleshooting)

Harika bir araç daha öğrendik. Şimdi sunucunun donanım kaynaklarını (CPU/RAM) sömüren durumları tespit etme günümüz.
5. Gün Senaryosu: "Sunucu Kilitleniyor, CPU %100!"

Müşteriler web sitesine girmeye çalıştığında "502 Gateway Error" alıyor. Sunucuya zar zor SSH attın, terminal aşırı yavaş tepki veriyor. Belli ki içeride sistemi boğan bir şeyler var.
Senden İstenen Adımlar:

## 1. Sunucudaki anlık CPU, Bellek (RAM) kullanımını ve en çok kaynak tüketen süreçleri (process) canlı olarak izlemek için hangi terminal aracını/araçlarını (top dışında daha modern bir alternatif de olabilir) kullanırsın?

## 2. İncelemende, zombi_islem adında bir Python script'inin arka arkaya onlarca süreç açtığını ve CPU'yu %100 tükettiğini gördün. Bu sürecin PID (Process ID) numarasının 4523 olduğunu varsayalım. Bu süreci sistemden en agresif ve kesin şekilde (sinyal göndererek) nasıl sonlandırırsın (öldürürsün)?

## 3. Bazen bir süreç (process) arka planda takılı kalır ama o an hangi dosyaları okuduğunu veya hangi network portunu kullandığını bilmek isteriz. Çalışan bir PID'nin (örneğin yine 4523) sistemde açtığı tüm dosyaları ve network soketlerini listelemek için hangi Linux komutunu kullanırsın?



## 1. Adım: Canlı Sistem İzleme (Ezber Bozan Modern Araçlar)

Sistem kilitlendiğinde veya yavaşladığında top komutu varsayılan olarak her Linux'ta bulunur ama okunması zordur. Kurumsal dünyada tüm SysAdmin'lerin ilk yüklediği modern araç htop'tur.

Terminale htop yazdığında karşına renkli, CPU çekirdeklerini tek tek gösteren, RAM kullanımını bar şeklinde veren ve süreçleri kolayca sıralayabileceğin interaktif bir ekran gelir.

Eğer sunucuda htop yoksa, anlık disk trafiğini görmek için iotop, network trafiğini görmek için ise iftop komutlarını kullanırız.


## 2. Adım: Süreçleri Sonlandırmak ve Zombi İşlemler (Yeni Bilgi 🚀)

Bir süreci en agresif şekilde öldürmek için ona SIGKILL (9) sinyali göndeririz. Bu sinyal sürece "işini bitirmeni beklemiyorum, hemen kapan" der.

```bash
# 4523 PID'li süreci kesin olarak öldürmek için:
sudo kill -9 4523
```

Zombi İşlem (Zombie Process) Nedir ve Nasıl Tespit Edilir?
Linux'ta bir alt süreç (child process) görevini bitirdiğinde, işletim sistemine "ben bittim" der. Ancak onu başlatan ana süreç (parent process) bu cevabı alıp onaylamazsa, o alt süreç sistemde "Zombi" olarak kalır. RAM veya CPU tüketmezler ama sistemin süreç tablosunda yer kaplarlar.

Tespit Etmek: Terminale top veya htop yazdığında sağ üst köşede ```Tasks: ... total, ... running, ... sleeping, 2 zombie``` gibi bir ibare görürsün.

Eğer sistemdeki zombi işlemlerin PID numaralarını listelemek istersen şu komutu kullanırsın:

```bash
ps aux | awk '{ print $8 " " $2 }' | grep -i Z
```

(Burada durum kodu Z olan süreçler zombidir. Zombi işlemler ```kill -9``` ile doğrudan ölmezler, çünkü zaten ölüdürler! Onları temizlemek için onları doğuran ana süreci (Parent PID) bulup yeniden başlatmak gerekir).



3. Adım: Bir Sürecin Açtığı Dosyaları Bulmak (Yeni Bilgi 🚀)

Linux dünyasında her şey bir dosyadır (klasörler, network soketleri, donanımlar...). Bir sürecin arka planda ne karıştırdığını görmek için ```lsof``` (List Open Files) komutunu kullanırız. SysAdmin'lerin en çok kullandığı komutlardan biridir.

```bash
# 4523 PID'li sürecin açık tuttuğu tüm dosyaları ve network bağlantılarını listeler:
sudo lsof -p 4523
```


# 6. Gün: Zamanlanmış Görevler ve Otomasyon (Cronjobs & Bash Scripting)

Şimdiye kadar disk kurtardın, kullanıcı yetkilendirdin, network çözdün, log döndürdün ve süreçleri yönettin. Şimdi bunları otomatize etme zamanı.
6. Gün Senaryosu: "Otomatik Yedekleme ve Temizlik"

Şirket, her gece yarısı saat 03:00'te /var/www/html dizininin yedeğinin (tar.gz formatında) alınmasını ve /backup dizinine yüklenmesini istiyor. Ayrıca diskte yer kaplamasın diye /backup dizinindeki 30 günden eski yedeklerin otomatik silinmesini istiyorlar.
Senden İstenen Adımlar:

## 1. /backup dizini altındaki 30 günden eski ve ismi .tar.gz ile biten dosyaları bulup tek komutla silecek o meşhur find komutunu nasıl yazarsın?

## Bu işlemi otomatikleştirmek için Linux'un zamanlanmış görev servisi olan Cron'u kullanacağız. crontab -e komutu ile editörü açtığını varsayalım. Her gece saat 03:00'te çalışacak bir görevi (cron satırını) nasıl tanımlarsın? (Zamanlama yıldızlarını * * * * * mantığına göre dizmeni bekliyorum).

İpucu: Cron zamanlaması Dakika Saat Ayın_Günü Ay Haftanın_Günü şeklindedir.


## 1. Adım: Eski Dosyaları Bulup Silmek (Puan: 10/10)

```find /backup -type f -name "*.tar.gz" -mtime +30 -exec rm -f {} \;```

Bu komut adeta bir İsviçre çakısıdır ve tam puanı hak ediyor.

```-type f```: Sadece dosyaları hedef alarak dizinleri yanlışlıkla silmeni engeller.

```-name "*.tar.gz"```: Sadece yedek dosyalarını seçer, yapılandırma veya diğer önemli dosyaları korur.

```-mtime +30```: Değiştirilme zamanı (modification time) 30 günden eski olanları filtreler.

```-exec rm -f {} \;```: Bulunan her bir dosyayı ({}) sırayla güvenli ve zorlayıcı şekilde (rm -f) siler. \; ise komutun bittiğini find mekanizmasına bildirir.


## 2. Adım: Cron Zamanlaması ve Akıllı Alternatif (Puan: 10/10)

```0 3 * * * find /backup -type f -name "*.tar.gz" -mtime +30 -delete```

Kesinlikle kullanabilirsin ve hatta bu çözüm 1. adımdaki yöntemden daha performanslıdır!

Zamanlama (``` 0 3 * * * ```): Tam olarak her gece saat 03:00'ü ifade eder.

```-delete``` Parametresi (Senior Detayı): İlk adımda yazdığın ```-exec rm -f {} \;``` yöntemi, bulunan her dosya için arka planda yeni bir rm süreci (process) başlatır. Eğer silinecek binlerce dosya varsa bu durum sistemi yorabilir. Ancak senin cron içine yazdığın -delete parametresi, yerleşik (built-in) bir find yeteneğidir. Yeni bir süreç başlatmadan dosyaları doğrudan siler. Çok daha hızlı ve sistem dostudur.































# 21. Gün: Bellek Canavarlarını Yakalamak

Karşımızda yine çok popüler bir Senior SysAdmin krizi var. Veri tabanının durup dururken kapanması kurumsal dünyada kırmızı alarmdır.
Senden İstenen Adımlar:

## 1. Linux'ta fiziksel RAM ve Swap alanı tamamen tükendiğinde, işletim sisteminin kilitlenmesini önlemek için en çok RAM tüketen büyük süreçleri acımasızca seçip öldüren bu yerleşik Kernel mekanizmasının adı nedir?

## 2. Bu mekanizmanın PostgreSQL'i gerçekten öldürüp öldürmediğini kanıtlamak için, doğrudan çekirdeğin (Kernel) loglarını barındıran dmesg komutunu hangi kelimeyle filtreleyerek ararsın? (Loglarda neyi avlamamız gerekir?)

## 3. Bu tarz bir krizin gelecekte tekrar yaşanmasını önlemek adına, Linux Kernel'ının "RAM sıkıştığında ne kadar kolay/agresif bir şekilde Swap alanına geçiş yapacağını" belirleyen o meşhur swappiness değeri varsayılan olarak kaç gelir ve kurumsal veri tabanı sunucularında (PostgreSQL/Oracle/MSSQL) performans için kaça düşürülmesi önerilir?



Gelin bu kurumsal dünyada çok can yakan OOM Killer konusunu ve veri tabanı sunucularının can damarı olan Swappiness ayarını derinlemesine inceleyelim.

## 1. Adım: Acımasız İnfazcı: OOM Killer (Out of Memory Killer)

Söylediğin killall komutu, biz yöneticilerin terminalden elle çalıştırdığı, "X ismindeki tüm süreçleri kapat" dediğimiz bir araçtır.

Soruda bahsettiğim, RAM bittiğinde sistem kilitlenmesin diye Kernel'ın otomatik devreye aldığı mekanizmanın adı OOM Killer (Out of Memory Killer)'dır.

Nasıl Çalışır? Sistemde RAM ve Swap tamamen bitince Kernel panikler. Eğer hiçbir şeyi kapatmazsa tüm işletim sistemi donacaktır. OOM Killer hemen devreye girer, süreçlerin RAM tüketimlerine ve çalışma sürelerine bakarak bir "kötülük puanı" (OOM Score) hesaplar. Sunucuda en çok RAM'i genellikle veri tabanı (PostgreSQL) tükettiği için, OOM Killer gider ve en büyük süreç olan PostgreSQL'i sistem yaşasın diye acımasızca vurur.

## 2. Adım: Suçüstü Yakalamak (Puan: 8/10)

dmesg | grep postgresql komutu sana PostgreSQL ile ilgili Kernel loglarını getirir, çok mantıklı. Ancak bazen loglarda sadece servisin öldüğü yazar, onu kimin öldürdüğü net çıkmaz.

OOM Killer'ın tetiği çektiğini kesin olarak kanıtlamak ve adli bilişim (forensics) raporu hazırlamak için doğrudan mekanizmanın kendi adını aratırız:

```bash
sudo dmesg | grep -i -E 'oom|killed process'
# veya daha genel loglardan bakmak için:
sudo grep -i 'killed process' /var/log/syslog
``` 

Bu komutun çıktısında tam olarak şu satırı yakalarsın:
Out of memory: Killed process 4523 (postgres) total-vm:16384kB, anon-rss:8192kB, file-rss:0kB, shmem-rss:0kB
Bu satırı gördüğün an yazılımcılara veya yönetime sunum yapabilirsin: "Sorun yazılımsal değil, sunucunun RAM'i yetersiz geldiği için işletim sistemi servisi korumak amacıyla kapatmış."


## 3. Adım: Swappiness Ayarı (Yeni Bilgi 🚀)

Swappiness, Linux Kernel'ının fiziksel RAM'deki verileri diskteki Swap alanına taşımak için ne kadar istekli olduğunu belirleyen 0 ile 100 arasında bir değerdir.

Varsayılan Değer: Birçok Linux dağıtımında (Ubuntu, CentOS) varsayılan olarak 60 gelir. Bu, "RAM %40 civarına geldiğinde yavaş yavaş Swap kullanmaya başla" demektir.

Kurumsal Veri Tabanı Standardı: PostgreSQL, Oracle veya MS SQL gibi yüksek performanslı veri tabanı sunucularında disk operasyonları çok yoğundur. Eğer Kernel erkenden Swap kullanmaya kalkarsa veri tabanı ciddi şekilde yavaşlar. Bu yüzden kurumsal dünyada veri tabanı sunucularında swappiness değeri 10 veya 1 seviyesine düşürülür!

Bu ayarı nasıl kontrol eder ve kalıcı değiştiririz?

```bash
# Anlık swappiness değerini görmek için:
cat /proc/sys/vm/swappiness

# Geçici olarak 10'a düşürmek için:
sudo sysctl vm.swappiness=10

# Sunucu reboot olduğunda da kalıcı olması için:
# /etc/sysctl.conf dosyasının en altına şu satır eklenir:
vm.swappiness = 10
```



# 22. Gün: Disk Bölümleme ve Dosya Sistemi Oluşturma (Fdisk, Gparted ve Mkfs)

LVM konusunu ilk gün konuşmuştuk. Şimdi LVM olmadan, sisteme yeni eklenen yalın bir diski sıfırdan bölümlere ayırıp (partitioning) formatlamayı öğreneceğiz.
22. Gün Senaryosu: "Sıfır Kilometre Disk Yapılandırması"

Şirketteki yedekleme sunucusuna fiziksel olarak 1 TB boyutunda yeni bir SSD disk takıldı. Sistem bu diski /dev/sdc olarak gördü. Bu disk şu an tamamen ham (raw) durumda; içinde ne bir bölüm var ne de bir dosya sistemi.

Senden istenen bu diski tek bir parça halinde bölümlendirip, kurumsal Linux standardı olan EXT4 dosya sistemiyle formatlaman ve kullanıma hazır hale getirmen.

Senden İstenen Adımlar:

## 1. Bu tamamen ham durumdaki /dev/sdc diskinin içerisine girip yeni bir bölüm (partition) oluşturmak için kullandığımız o geleneksel terminal aracı nedir?

## 2. Bölümleme bitti ve artık elinde /dev/sdc1 var. Bu birimi EXT4 formatında biçimlendirmek (formatlamak) için hangi komutu kullanırsın?

## 3. Her şey bitti. Bu yeni diski /etc/fstab dosyasına güvenle eklemek için disklerin o benzersiz kimlik numarasını (UUID) öğrenmemiz gerekir. Bir diskin veya bölümün UUID değerini ekrana basan o pratik komut hangisidir?