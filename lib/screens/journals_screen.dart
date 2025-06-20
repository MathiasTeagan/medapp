import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/journals_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/branch_selector.dart';
import '../models/journal.dart';
import '../theme/app_colors.dart';
import '../theme/text_styles.dart';

class JournalsScreen extends StatefulWidget {
  const JournalsScreen({super.key});

  @override
  State<JournalsScreen> createState() => _JournalsScreenState();
}

class _JournalsScreenState extends State<JournalsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Kullanıcının branşını ayarla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();
      if (userProvider.specialty.isNotEmpty) {
        context
            .read<JournalsProvider>()
            .setSelectedBranch(userProvider.specialty);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dergiler'),
      ),
      body: Consumer2<JournalsProvider, UserProvider>(
        builder: (context, journalsProvider, userProvider, child) {
          return Column(
            children: [
              // Branch Selector
              Padding(
                padding: EdgeInsets.fromLTRB(
                    size.width * 0.04, size.width * 0.04, size.width * 0.04, 8),
                child: BranchSelector(
                  selectedBranch: journalsProvider.selectedBranch,
                  onBranchSelected: (branch) {
                    journalsProvider.setSelectedBranch(branch);
                  },
                  labelText: 'Branş Seçiniz',
                ),
              ),

              // TabBar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200.withOpacity(0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.primary,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey.shade600,
                  labelStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: const [
                    Tab(text: 'Dergiler'),
                    Tab(text: 'Makaleler'),
                  ],
                ),
              ),

              // Error Message
              if (journalsProvider.error != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade600),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          journalsProvider.error!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                      IconButton(
                        onPressed: journalsProvider.clearError,
                        icon: const Icon(Icons.close),
                        color: Colors.red.shade600,
                      ),
                    ],
                  ),
                ),

              // TabBarView
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Dergiler Tab
                    _buildJournalsTab(journalsProvider),
                    // Makaleler Tab
                    _buildArticlesTab(journalsProvider),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildJournalsTab(JournalsProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (provider.selectedBranch == null) {
      return _buildEmptyState('Lütfen bir branş seçiniz');
    }

    if (provider.journals.isEmpty) {
      return _buildEmptyState('Bu branş için henüz dergi bulunmuyor');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.journals.length,
      itemBuilder: (context, index) {
        final journal = provider.journals[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Text(
                journal.name[0],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              journal.name,
              style: AppTextStyles.titleMedium(context),
            ),
            subtitle: journal.description != null
                ? Text(
                    journal.description!,
                    style: AppTextStyles.bodyMedium(context),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  )
                : null,
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              provider.loadArticlesForJournal(journal);
              _tabController.animateTo(1); // Makaleler tab'ına geç
            },
          ),
        );
      },
    );
  }

  Widget _buildArticlesTab(JournalsProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (provider.selectedBranch == null) {
      return _buildEmptyState('Lütfen bir branş seçiniz');
    }

    if (provider.journals.isEmpty) {
      return _buildEmptyState('Bu branş için henüz dergi bulunmuyor');
    }

    if (provider.articles.isEmpty) {
      return _buildEmptyState('Henüz makale yüklenmedi\nBir dergi seçiniz');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.articles.length,
      itemBuilder: (context, index) {
        final article = provider.articles[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.title,
                  style: AppTextStyles.titleMedium(context).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (article.author?.isNotEmpty == true) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Yazar: ${article.author}',
                    style: AppTextStyles.bodySmall(context).copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
                if (article.pubDate != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Yayın Tarihi: ${_formatDate(article.pubDate!)}',
                    style: AppTextStyles.bodySmall(context).copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
                if (article.description?.isNotEmpty == true) ...[
                  const SizedBox(height: 12),
                  Text(
                    article.description!,
                    style: AppTextStyles.bodyMedium(context),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (article.link?.isNotEmpty == true) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _launchUrl(article.link!),
                        icon: const Icon(Icons.open_in_new, size: 16),
                        label: const Text('Makaleyi Aç'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          minimumSize: const Size(0, 36),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTextStyles.titleMedium(context).copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Link açılamadı')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }
}
