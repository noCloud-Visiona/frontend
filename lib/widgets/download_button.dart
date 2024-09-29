import 'package:flutter/material.dart';

class DownloadButton extends StatelessWidget {
  final VoidCallback onDownloadImage;
  final VoidCallback onDownloadPdf;

  const DownloadButton({
    super.key,
    required this.onDownloadImage,
    required this.onDownloadPdf, required void Function() onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.download),
          label: const Text('Download Imagem'),
          onPressed: onDownloadImage,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF176B87),
            foregroundColor: Colors.white,
            shadowColor: Colors.black,
            elevation: 5,
            side: const BorderSide(color: Colors.white, width: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            minimumSize: const Size(48, 48),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton.icon(
          icon: const Icon(Icons.picture_as_pdf),
          label: const Text('Download PDF'),
          onPressed: onDownloadPdf,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF176B87),
            foregroundColor: Colors.white,
            shadowColor: Colors.black,
            elevation: 5,
            side: const BorderSide(color: Colors.white, width: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            minimumSize: const Size(48, 48),
          ),
        ),
      ],
    );
  }
}