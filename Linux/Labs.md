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

