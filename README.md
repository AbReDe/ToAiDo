📱 Proje Özeti: ToAiDo (To-Do + AI + Do)
ToAiDo, yazılımcılar ve mühendisler için geliştirilmiş, Yapay Zeka (Google Gemini) destekli, sosyal etkileşimli ve takım çalışmasına uygun bir Mobil Proje ve Görev Yönetim Uygulamasıdır.
Sıradan bir "Yapılacaklar Listesi" uygulamasının ötesine geçerek; arkadaş ekleme, ortak proje yürütme ve yapay zekaya görev planlatma gibi gelişmiş özellikler sunar.
________________________________________
🏗️ Mimari ve Teknoloji Yığını (Tech Stack)
Tamamen Full Stack ve Modern Mimari prensiplerine sadık kalınarak geliştirilmiştir.
1. Frontend (Mobil Uygulama)
•	Dil: Dart / Flutter
•	State Management (Durum Yönetimi): GetX (Reaktif programlama ve hızlı performans için).
•	Mimari: MVC (Model - View - Controller) yapısı. Kodlar Servis, Kontrolcü ve Arayüz olarak ayrıştırıldı.
•	Depolama: FlutterSecureStorage ile JWT Token ve API anahtarları şifreli saklanıyor.
•	Bağlantı: GetConnect ile REST API haberleşmesi.
2. Backend (Sunucu ve API)
•	Dil: Python
•	Framework: FastAPI (Yüksek performans ve asenkron yapı için).
•	Veritabanı: PostgreSQL (İlişkisel veritabanı - Relational DB).
•	ORM: SQLAlchemy (Veritabanı tablolarını Python nesneleri olarak yönetmek için).
•	Şema Doğrulama: Pydantic (Gelen/Giden verinin doğruluğunu garanti etmek için).
•	Güvenlik: OAuth2 ve JWT (JSON Web Token) tabanlı kimlik doğrulama.
________________________________________
🌟 Temel Özellikler (Modüller)
1. 🔐 Güvenli Kimlik Doğrulama (Auth)
•	Kullanıcı Kayıt ve Giriş sistemi.
•	Şifreler veritabanında Hash (şifreli) olarak saklanır.
•	Giriş yapan kullanıcıya süreli bir JWT Token verilir, tüm işlemler bu token ile yapılır.
•	Splash Screen: Uygulama açılışında token kontrolü yapar, oturum geçerliyse otomatik giriş sağlar.
2. ✅ Gelişmiş Görev Yönetimi (Personal Tasks)
•	Kullanıcılar kişisel görevlerini ekleyebilir, silebilir ve tamamlayabilir.
•	Öncelik Sistemi: Yüksek (Kırmızı), Orta (Turuncu), Düşük (Yeşil) renk kodları.
•	Etiketleme (Tags): Görevlere #yazılım, #spor gibi etiketler eklenebilir.
•	Tekrarlayan Görevler (Recurring Tasks): "Her Gün" veya "Her Hafta" seçeneği. Sistem, tamamlanan tarihleri loglar ve ertesi gün görevi tekrar "Yapılacak" olarak gösterir.

3. 📁 Proje ve Takım Yönetimi (Collaboration)
•	Kullanıcılar Projeler oluşturabilir.
•	Arkadaş Davet Sistemi: Projeye arkadaşını davet edebilirsin. Arkadaşın "Davetler" sekmesinde bunu görür ve kabul ederse projeye dahil olur.
•	Ortak Görev Havuzu: Proje içindeki görevleri tüm üyeler görür.
•	Görev Sahipliği (Assignment): Bir görevi "Üstlen" diyerek kendine alabilirsin. O görev artık senindir ve başkası alamaz. "Bırak" diyerek havuza geri atabilirsin.

4. 🤝 Sosyal Ağ (Friend System)
•	Kullanıcı Arama: İsim veya kullanıcı adıyla arama yapıp kişi bulma.
•	Arkadaşlık İsteği: İstek gönderme, Bekleyen İstekleri görme, Kabul/Red etme.
•	Bildirim: Profilde bekleyen istek varsa kırmızı nokta (Red Dot) ile uyarı verme.

5. 🤖 Yapay Zeka Asistanı (AI Integration)
•	Google Gemini 2.0 Entegrasyonu: En güncel ve hızlı AI modeli.
•	Sohbet Modu: AI ile teknik konularda sohbet edilebilir.
•	Görev Oluşturucu (Generator): "1 haftada Python öğrenmek istiyorum" dediğinde, AI sana gün gün yapman gerekenleri listeler. Tek tıkla bu önerileri kendi takvimine görev olarak ekleyebilirsin.
•	Kişisel API Key: Her kullanıcı kendi API anahtarını girerek sistemi kullanır (Maliyet ve kota yönetimi için).

6. 👤 Profil Yönetimi
•	Avatar Yükleme: Galeriden fotoğraf seçip sunucuya yükleme (uploads klasörü).
•	İstatistikler: Toplam görev, biten görev ve arkadaş sayısını anlık görme.
•	Bilgi Güncelleme: İsim, email ve şifreli API Key güncellem
