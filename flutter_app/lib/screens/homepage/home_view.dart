// lib/views/home_view.dart

import 'package:flutter/material.dart';
import 'package:get_x/get.dart';

import 'package:table_calendar/table_calendar.dart'; // Takvim paketi
import 'package:intl/intl.dart';

import '../../models/task.dart';
import '../AddTaskPage/add_task_view.dart';
import '../ProjectPage/view/project_view.dart';
import '../ai/ai_chat_view.dart';
import '../profil_page/profile_view.dart';
import 'home_controller.dart'; // Tarih formatlama


class HomeView extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());

  HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "ToAiDo",
          style: TextStyle(
            color: Color(0xFF1E3C72),
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 1,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black54),
            onPressed: () {},
          )
        ],
      ),

      // --- BODY (İçerik) ---
      body: Obx(() {
        if (controller.selectedIndex.value == 0) {
          return _buildHomeContent();
        }
        else if (controller.selectedIndex.value == 1) {
          return ProjectView();
        } else if (controller.selectedIndex.value == 2) {
          return AIChatView();
        } else {
          return ProfileView();
        }
      }),

      // --- FLOATING ACTION BUTTON (Görev Ekleme) ---
      floatingActionButton: Obx(() {

        if (controller.selectedIndex.value == 0) {
          return FloatingActionButton(
            onPressed: () {
              // Görev ekleme sayfasına git
              Get.to(() => AddTaskView(), transition: Transition.downToUp);
            },
            backgroundColor: const Color(0xFF1E3C72),
            child: const Icon(Icons.add, color: Colors.white),
          );
        }

        else {
          return const SizedBox.shrink();
        }
      }),

      // FAB'ı BottomBar'ın ortasına gömmek için (Opsiyonel, şık durur)
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // --- BOTTOM NAVIGATION BAR (Alt Menü) ---
      bottomNavigationBar: Obx(() => NavigationBar(
        selectedIndex: controller.selectedIndex.value,
        onDestinationSelected: (index) => controller.changeTabIndex(index),
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFF1E3C72).withOpacity(0.2),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Color(0xFF1E3C72)),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder, color: Color(0xFF1E3C72)),
            label: 'Projeler',
          ),
          NavigationDestination(
            icon: Icon(Icons.smart_toy_outlined), // AI İkonu
            selectedIcon: Icon(Icons.smart_toy, color: Color(0xFF1E3C72)),
            label: 'AI Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: Color(0xFF1E3C72)),
            label: 'Profil',
          ),
        ],
      )),
    );
  }

  // --- ANA EKRAN İÇERİĞİ (Takvim ve Görevler) ---
  Widget _buildHomeContent() {
    return Column(
      children: [
        // 1. TAKVİM ALANI (Modern Haftalık Görünüm)
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Obx(() => TableCalendar(
            firstDay: DateTime.utc(2020, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: controller.focusedDate.value,
            currentDay: controller.selectedDate.value,
            calendarFormat: CalendarFormat.week, // Sadece haftayı göster
            availableCalendarFormats: const {CalendarFormat.week: 'Hafta'},
            startingDayOfWeek: StartingDayOfWeek.monday, // Pazartesiden başlasın

            // Stil Ayarları
            calendarStyle: CalendarStyle(
              selectedDecoration: const BoxDecoration(
                color: Color(0xFF1E3C72),
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: const Color(0xFF1E3C72).withOpacity(0.4),
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false, // "Hafta" butonunu gizle
              titleCentered: true,
            ),

            // Tıklama Olayı
            onDaySelected: controller.onDaySelected,
          )),
        ),

        // 2. "GÖREVLER" BAŞLIĞI
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Günün Görevleri",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Obx(() => Text(
                DateFormat('d MMMM', 'tr_TR').format(controller.selectedDate.value), // Örn: 14 Aralık
                style: const TextStyle(color: Colors.grey),
              )),
            ],
          ),
        ),

        // 3. GÖREV LİSTESİ
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.taskList.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_available, size: 80, color: Colors.grey.shade300),
                    const SizedBox(height: 10),
                    const Text("Bugün için görev yok.", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: controller.taskList.length,
              itemBuilder: (context, index) {
                // ARTIK BU BİR TASK NESNESİ
                Task task = controller.taskList[index];

                return Dismissible(
                  key: Key(task.id.toString()), // task['title'] yerine task.id
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    controller.deleteTask(index);
                  },
                  background: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.delete_outline, color: Colors.white, size: 30),
                  ),
                  child: _buildTaskCard(task, index), // Task nesnesini gönderiyoruz
                );
              },
            );
          }),
        ),
      ],
    );
  }

  // --- GÖREV KARTI (DÜZELTİLDİ) ---
  Widget _buildTaskCard(Task task, int index) {
    // --- KRİTİK GÜNCELLEME: YENİ TAMAMLANMA MANTIĞI ---
    // Seçili günün tarihini al (YYYY-MM-DD formatında)
    String selectedDateStr = DateFormat('yyyy-MM-dd').format(controller.selectedDate.value);

    // Görev tamamlandı mı?
    // 1. completedDates listesinde bu tarih var mı? (Tekrarlı görevler için)
    // 2. VEYA task.status "Tamamlandı" mı? (Eski usül tek seferlik görevler için yedek kontrol)
    bool isCompleted = task.completedDates.contains(selectedDateStr) || task.status == "Tamamlandı";

    // Öncelik Rengi Belirleme
    Color priorityColor;
    switch (task.priority) {
      case 'high': priorityColor = Colors.redAccent; break;
      case 'medium': priorityColor = Colors.orange; break;
      case 'low': priorityColor = Colors.green; break;
      default: priorityColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight( // Yükseklikleri eşitlemek için
          child: Row(
            children: [
              // 1. ÖNCELİK ÇİZGİSİ (SOLDAKİ RENKLİ ŞERİT)
              Container(
                width: 6,
                color: priorityColor,
              ),

              // 2. İÇERİK
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- PROJE ETİKETİ (Varsa) ---
                      if (task.projectId != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          margin: const EdgeInsets.only(bottom: 6),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.folder_outlined, size: 12, color: Color(0xFF1E3C72)),
                              SizedBox(width: 4),
                              Text(
                                  "Proje Görevi",
                                  style: TextStyle(fontSize: 10, color: Color(0xFF1E3C72), fontWeight: FontWeight.bold)
                              ),
                            ],
                          ),
                        ),

                      // BAŞLIK VE TOGGLE BUTONU
                      Row(
                        children: [
                          InkWell(
                            onTap: () => controller.toggleTaskStatus(index),
                            child: Container(
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: isCompleted ? Colors.green : Colors.grey,
                                    width: 2
                                ),
                                color: isCompleted ? Colors.green : null,
                              ),
                              child: isCompleted
                                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                                  : const SizedBox(width: 14, height: 14),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              task.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                decoration: isCompleted ? TextDecoration.lineThrough : null,
                                color: isCompleted ? Colors.grey : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // SAAT VE TEKRAR BİLGİSİ
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 12, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(
                            task.dueDate != null
                                ? DateFormat('HH:mm').format(task.dueDate!)
                                : "--:--",
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                          ),

                          const SizedBox(width: 10),

                          // Tekrar Bilgisi (Varsa göster)
                          if (task.repeat != null && task.repeat != "none")
                            Row(
                              children: [
                                Icon(Icons.repeat, size: 12, color: Colors.grey.shade500),
                                const SizedBox(width: 4),
                                Text(
                                  task.repeat == 'daily' ? 'Her Gün' :
                                  (task.repeat == 'weekly' ? 'Haftalık' : 'Aylık'),
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                                ),
                              ],
                            ),
                        ],
                      ),

                      // --- TAGLER (CHIPS) ---
                      if (task.tags.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: task.tags.map((tag) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Text(
                              "#$tag",
                              style: TextStyle(fontSize: 10, color: Colors.grey.shade700, fontStyle: FontStyle.italic),
                            ),
                          )).toList(),
                        )
                      ]
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}