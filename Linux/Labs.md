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