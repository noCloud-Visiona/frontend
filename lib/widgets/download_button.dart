import 'package:flutter/material.dart';

class DownloadButton extends StatelessWidget {
  final VoidCallback onDownloadImage;
  final VoidCallback onDownloadPdf;

  const DownloadButton({
    super.key,
    required this.onDownloadImage,
    required this.onDownloadPdf,
    required void Function() onDownload,
  });

 @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
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
              minimumSize: const Size(40, 40), // Diminuído de 48 para 40
              padding: const EdgeInsets.symmetric(horizontal: 8), // Ajuste do padding
              textStyle: const TextStyle(fontSize: 14), // Ajuste do tamanho do texto
            ),
          ),
        
        const SizedBox(width: 8), // Diminuído de 10 para 8
       
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
              minimumSize: const Size(40, 40), // Diminuído de 48 para 40
              padding: const EdgeInsets.symmetric(horizontal: 8), // Ajuste do padding
              textStyle: const TextStyle(fontSize: 14), // Ajuste do tamanho do texto
            ),
          ),
        
      ],
    );
  }
}