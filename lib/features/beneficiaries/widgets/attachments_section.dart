import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import '../utils/attachments_manager.dart';
import '../../../core/providers/providers.dart';

/// 📎 Attachments Widget
class AttachmentsSection extends ConsumerStatefulWidget {
  final String beneficiaryId;
  final bool loadFromDatabase;

  const AttachmentsSection({
    super.key,
    required this.beneficiaryId,
    this.loadFromDatabase = false,
  });

  @override
  ConsumerState<AttachmentsSection> createState() => _AttachmentsSectionState();
}

class _AttachmentsSectionState extends ConsumerState<AttachmentsSection> {
  List<BeneficiaryAttachment> _attachments = [];
  bool _isLoading = false;
  bool _hasLoadedFromDb = false;

  @override
  void initState() {
    super.initState();
    // Load from database will happen in didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.loadFromDatabase && !_hasLoadedFromDb) {
      _hasLoadedFromDb = true;
      _loadAttachments();
    }
  }

  Future<void> _loadAttachments() async {
    debugPrint(
      '🔍 Loading attachments for beneficiary: ${widget.beneficiaryId}',
    );
    setState(() => _isLoading = true);
    try {
      final database = ref.read(databaseProvider);
      debugPrint('📊 Database obtained, fetching attachments...');
      final attachments = await AttachmentsManager.getAttachmentsFromDb(
        beneficiaryId: widget.beneficiaryId,
        database: database,
      );
      debugPrint('✅ Loaded ${attachments.length} attachments from database');
      setState(() {
        _attachments = attachments;
      });
    } catch (e) {
      debugPrint('❌ Error loading attachments: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addImageFromCamera() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (image != null) {
      await _addAttachment(File(image.path));
    }
  }

  Future<void> _addImageFromGallery() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage(
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (images.isNotEmpty) {
      setState(() => _isLoading = true);
      for (final image in images) {
        await _addAttachment(File(image.path));
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addPdfFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() => _isLoading = true);
      for (final file in result.files) {
        if (file.path != null) {
          await _addAttachment(File(file.path!));
        }
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addAttachment(File file) async {
    setState(() => _isLoading = true);

    try {
      final database = ref.read(databaseProvider);
      final attachment = await AttachmentsManager.addAttachmentWithDb(
        beneficiaryId: widget.beneficiaryId,
        sourceFile: file,
        database: database,
      );

      if (attachment != null) {
        setState(() {
          _attachments.add(attachment);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ تم إضافة المرفق بنجاح'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        throw Exception('فشل في إضافة المرفق');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✗ خطأ: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteAttachment(BeneficiaryAttachment attachment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المرفق'),
        content: Text('هل تريد حذف "${attachment.fileName}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);

      final database = ref.read(databaseProvider);
      final success = await AttachmentsManager.deleteAttachmentWithDb(
        attachment: attachment,
        database: database,
      );

      if (success) {
        setState(() {
          _attachments.remove(attachment);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ تم حذف المرفق'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }

      setState(() => _isLoading = false);
    }
  }

  Future<void> _viewAttachment(BeneficiaryAttachment attachment) async {
    if (attachment.isImage) {
      // عرض الصورة في dialog
      await showDialog(
        context: context,
        builder: (context) => Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                title: Text(attachment.fileName),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Flexible(
                child: InteractiveViewer(
                  child: Image.file(
                    File(attachment.filePath),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else if (attachment.isPdf) {
      // فتح PDF في تطبيق خارجي
      await OpenFile.open(attachment.filePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Icon(
              Icons.attach_file,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'المرفقات (${_attachments.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const Spacer(),
            if (_isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Add buttons
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildAddButton(
              icon: Icons.camera_alt,
              label: 'كاميرا',
              onPressed: _addImageFromCamera,
            ),
            _buildAddButton(
              icon: Icons.photo_library,
              label: 'معرض الصور',
              onPressed: _addImageFromGallery,
            ),
            _buildAddButton(
              icon: Icons.picture_as_pdf,
              label: 'PDF',
              onPressed: _addPdfFile,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Attachments grid
        if (_attachments.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            alignment: Alignment.center,
            child: Column(
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'لا توجد مرفقات',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: _attachments.length,
            itemBuilder: (context, index) {
              final attachment = _attachments[index];
              return _buildAttachmentTile(attachment);
            },
          ),
      ],
    );
  }

  Widget _buildAddButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: _isLoading ? null : onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildAttachmentTile(BeneficiaryAttachment attachment) {
    return GestureDetector(
      onTap: () => _viewAttachment(attachment),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Content
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: attachment.isImage
                  ? Image.file(
                      File(attachment.thumbnailPath ?? attachment.filePath),
                      fit: BoxFit.cover,
                    )
                  : _buildPdfPreview(attachment),
            ),

            // Delete button
            Positioned(
              top: 4,
              right: 4,
              child: Material(
                color: Colors.black54,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: () => _deleteAttachment(attachment),
                  customBorder: const CircleBorder(),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.close, color: Colors.white, size: 16),
                  ),
                ),
              ),
            ),

            // File info
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: Text(
                  attachment.fileSizeReadable,
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfPreview(BeneficiaryAttachment attachment) {
    return Container(
      color: Colors.red[50],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.picture_as_pdf, size: 40, color: Colors.red[700]),
          const SizedBox(height: 4),
          Text(
            'PDF',
            style: TextStyle(
              fontSize: 12,
              color: Colors.red[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
