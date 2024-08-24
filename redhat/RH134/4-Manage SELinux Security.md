SELinux (Security-Enhanced Linux) Linux’ da zorunlu erişim denetimi (MAC) mekanizmasına gerçekleşmesini sağlayan bir projedir.

 
DAC ve MAC

 
İsteğe bağlı erişim denetimi (DAC) altında, bir kullanıcı veya sürecin dosyalara, socketlere ve diğer kaynaklara erişip erişemeyeceği kullanıcı sahipliğine veya izinlere bakarak belirlenir.

 
Zorunlu erişim denetimi ise (MAC) kullanıcıların (subjects) oluşturdukları nesnelern (objects) üzerindeki denetim düzeyini kısıtlayan bir güvenlik mekanizmasıdır. İsteğe bağlı erişim denetimi kontrolünde kullanıcılar kendi dosya, dizin, vb üzerinde tam denetime sahipken, zorunlu erişim denetimi tüm dosya sistemi nesneleri için, ek etiket ya da kategori ekler. Kullanıcılar ve süreçlerin bu nesnelerle erişebilmesi için bu kategorilere uygun erişim hakları olmalıdır.

 
İsteğe bağlı erişim kontrolünde tüm erişim kararları kullancının kimliği ve sahipliğine göre verilir. Bu da güvenlik açığından faydalanılıp kötü amaçlı kullanılan bir uygulamanın kullanıcısının sahibi olduğu ve erişebildiği tüm kaynakları dilediği gibi kullanacağı anlamına gelmektedir. SELinux ile kullanıcı ve o kullanıcının sahip olduğu haklar farklılaştırılabilir. Örneğin; bir bir shell veya GUI aracılığı ile sistemde oturum açmış kullanıcı kendi ev dizininde istediğini yapmasına izin verilebilirken, o kullanıcının çalıştırdığı bir uygulamanın bu ev dizininde bazı dosya veya dizinlere erişimi kısıtlanabilir.

 
SELinux Nasıl Çalışır ?

 

 
Bir subject (örneğin bir uygulama) bir objecte (örneğin bir dosya) erişmeye çalıştığında çekirdekteki politika uygulama sunucusu subject ve object izinleri için öncelikle erişim vektörü önbelleğini (Access Vector Cache) kontrol eder. Eğer önbelleğe bakılarak karar verilemezse sunucu güvenlik politikalarına göre erişimin gerçekleşip gerçekleşmeyeceğini belirler. Ayrıca söylemekte fayda var SELinux DAC’ta belirlenen erişim kurallarını ezmez.

 
SELinux Modları

 
SELinux’un 3 modu vardır. Bunlar:

 
enforcing: Kaynaklara erişimin SELinux politikasına göre belirlendiği moddur.
permissive: Bu modda erişimler SELinux politikası zorlanmaz. Ancak erişim politikasına uymayan durumlar bir günlük dosyasına yazılır. (Redhat’te /var/log/audit/audit.log dosyasına varsayılan olarak yazılır)
disabled: SELinux tamamen devre dışıdır. Sadece DAC kuralları geçerlidir.
 
SELinux’u /etc/selinux/config dosyasını kullanarak yapılandırabilirsiniz.


 This file controls the state of SELinux on the system.SELINUX=enforcingSELINUXTYPE=targeted

SELINUX seçeneği ile SELinux’ un hangi modda çalışağını söylüyoruz. SELINUXTYPE ile de hangi SELinux politikasının uygulanacağını belirtmiş oluyoruz. Bunlar:

 
stricted: Erişim politikası sistemdeki tüm süreçler için işler.
targeted: Erişim politikası sadece hedeflenen süreçler için işler. (dhcpd, httpd, named, nscd, ntpd gibi)
mls: Çok seviyeli güvenlik koruması
 
getenforce ve sestatus komutları SELinux’un hangi modda olduğunu öğrenmek için kullanılabilir.


$getenforceEnforcing$sestatusSELinux status:                 enabledSELinuxfs mount:                /selinuxCurrent mode:                   enforcingMode from config file:          disabledPolicy version:                 24Policy from config file:        targeted

Aslında bu yazıyı yazmamdaki en büyük neden SELinux’ un Redhat’te varsayılan olarak enforced modda gelmesi ve benim bundan bihaber olmamdı. Sunucu üzerinde bir daemon için SELinux politikasında tanımlı olmayan port kullandığımda veya web sunucusunun mail sunucusunu kullanarak mail atmaya çalıştığında permission denied şeklinde uyarılar alıyordum. Böyle bir durumda /var/log/audit/audit.log günlük dosyasına bakarak politikaya uymayan erişim isteklerini görebiliriz.

 
audit.log dosyasından örnek bir satır:


type=AVC msg=audit(1375367543.933:109729): avc: denied { name_connect } for pid=2591 comm=”httpd” dest=25 scontext=unconfined_u:system_r:httpd_t:s0 tcontext=system_u:object_r:smtp_port_t:s0 tclass=tcp_socket

Bu satır bize pid:2591 olan httpd isimli süreç 25 numaralı porta porta bağlanmaya çalıştığını ancak erişimin reddedildiğini söylüyor. Çıktıyı daha okunabilir hale audit2allow komutuna -w(why) parametresini ekleyerek getirebiliriz:


#audit2allow -a -wWas caused by:Unknown - would be allowed by active policyPossible mismatch between this policy and the one under which the audit message was generated.Possible mismatch between current in-memory boolean settings vs. permanent ones.#audit2allow -a#============= httpd_t ==============allow httpd_t home_root_t:file getattr;#!!!! This avc can be allowed using one of the these booleans:#     httpd_can_sendmail, allow_ypbind, httpd_can_network_connectallow httpd_t smtp_port_t:tcp_socket name_connect;

Bu komutun çalışması sonucunda audit.log dosyasında ki reddedilen erişimlere izin verecek kuralları görebiliyoruz.


#audit2allow -a -M httpd_module

Komutu ile de httpd_module.pp isminde type enforcement kurallarının derlendiği bir politika paketi ve type enforcement kurallarının yazdığı httpd_module.te isimli iki dosya oluşuyor.

 
Modulü yüklemek içinde aşağıdaki komutu kullanıyoruz:


#semodule -i httpd_module.pp