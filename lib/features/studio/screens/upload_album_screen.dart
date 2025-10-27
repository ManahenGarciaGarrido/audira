import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../config/theme.dart';

class UploadAlbumScreen extends StatefulWidget {
  const UploadAlbumScreen({Key? key}) : super(key: key);

  @override
  State<UploadAlbumScreen> createState() => _UploadAlbumScreenState();
}

class _UploadAlbumScreenState extends State<UploadAlbumScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController(text: '19.99');
  final _releaseDateController = TextEditingController();

  bool _showPreview = false;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _coverImageFileName;
  List<String> _selectedSongs = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _releaseDateController.dispose();
    super.dispose();
  }

  Future<void> _pickCoverImage() async {
    setState(() => _coverImageFileName = 'album_cover.jpg');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Image file selection - Coming soon')),
    );
  }

  Future<void> _selectSongs() async {
    final songs = await showDialog<List<String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Songs'),
        content: const Text('Song selection dialog - Coming soon'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, []),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, ['Song 1', 'Song 2', 'Song 3']);
            },
            child: const Text('Select'),
          ),
        ],
      ),
    );

    if (songs != null) {
      setState(() => _selectedSongs = songs);
    }
  }

  Future<void> _uploadAlbum() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSongs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one song')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    for (var i = 0; i <= 100; i += 10) {
      await Future.delayed(const Duration(milliseconds: 200));
      setState(() => _uploadProgress = i / 100);
    }

    setState(() => _isUploading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Album uploaded successfully!')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Album'),
        actions: [
          IconButton(
            icon: Icon(_showPreview ? Icons.edit : Icons.preview),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                setState(() => _showPreview = !_showPreview);
              }
            },
          ),
        ],
      ),
      body: _showPreview ? _buildPreview() : _buildForm(),
      bottomNavigationBar: _isUploading
          ? Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Uploading... ${(_uploadProgress * 100).toInt()}%'),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: _uploadProgress),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.image, color: AppTheme.primaryBlue),
                title: Text(_coverImageFileName ?? 'Select Cover Image'),
                trailing: const Icon(Icons.upload_file),
                onTap: _pickCoverImage,
              ),
            ).animate().fadeIn(),
            const SizedBox(height: 16),

            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Album Title *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.album),
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Required' : null,
            ).animate().fadeIn(delay: 50.ms),
            const SizedBox(height: 16),

            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Price *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _releaseDateController,
                    decoration: const InputDecoration(
                      labelText: 'Release Date',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        _releaseDateController.text =
                            '${date.year}-${date.month}-${date.day}';
                      }
                    },
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 150.ms),
            const SizedBox(height: 24),

            Card(
              child: ListTile(
                leading: const Icon(Icons.music_note, color: AppTheme.primaryBlue),
                title: Text(_selectedSongs.isEmpty
                    ? 'Add Songs'
                    : '${_selectedSongs.length} songs selected'),
                trailing: const Icon(Icons.add),
                onTap: _selectSongs,
              ),
            ).animate().fadeIn(delay: 200.ms),

            if (_selectedSongs.isNotEmpty) ...[
              const SizedBox(height: 16),
              ..._selectedSongs.asMap().entries.map((entry) => Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primaryBlue,
                        child: Text('${entry.key + 1}'),
                      ),
                      title: Text(entry.value),
                      trailing: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setState(() => _selectedSongs.removeAt(entry.key));
                        },
                      ),
                    ),
                  )),
            ],

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isUploading ? null : _uploadAlbum,
                icon: const Icon(Icons.cloud_upload),
                label: const Text('Upload Album'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                ),
              ),
            ).animate().fadeIn(delay: 250.ms).scale(),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: AppTheme.surfaceBlack,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.album, size: 80, color: AppTheme.primaryBlue),
            ),
          ),
          const SizedBox(height: 24),

          Text(
            _titleController.text.isEmpty ? 'Album Title' : _titleController.text,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(_descriptionController.text, style: const TextStyle(color: AppTheme.textGrey)),
          const SizedBox(height: 16),

          Row(
            children: [
              const Icon(Icons.attach_money, color: AppTheme.primaryBlue),
              Text('\$${_priceController.text}',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
            ],
          ),
          const SizedBox(height: 24),

          const Text('Track List', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ..._selectedSongs.asMap().entries.map(
                (entry) => ListTile(
                  leading: Text('${entry.key + 1}'),
                  title: Text(entry.value),
                ),
              ),
        ],
      ),
    );
  }
}
