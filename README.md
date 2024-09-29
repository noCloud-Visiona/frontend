# Frontend - noCloud-Visiona

## Tecnologias Utilizadas
- Flutter (Dart)

## Estrutura Principal
O arquivo principal do projeto (`main.dart`) inicializa o aplicativo, configura o gerenciador de estado e define as principais rotas da aplicação.

## Funcionalidades da Aplicação
- **Login**: Tela inicial que permite o login do usuário.
- **Análise de Imagem de Satélite**: O usuário faz o upload de uma imagem do catálogo de imagens do INPE (CB4A-WPM-PCA-FUSED-1) no formato *.png disponível em:
  [http://www.dgi.inpe.br/catalogo/explore](http://www.dgi.inpe.br/catalogo/explore).
Esta imagem é analisada pelo serviço Identificação-IA e retorna a imagem analisada e a descrição.
- **Download da Imagem/PDF**: Após a análise, é possivel realizar o download da imagem ou de uma arquivo PDF contendo a imagem e a descrição.
- **Histórico do Usuário**: Histórico simples com todas as análises realizadas pelo usuário.

## Pré-Requisitos

Para rodar a aplicação, você precisará ter instalado:
- Flutter SDK
- Android Studio ou Visual Studio Code (como IDE)

## Clone o Repositório
```sh
https://github.com/noCloud-Visiona/frontend
```

## Instalando Dependências

```sh
flutter pub get
```

## Rodar Aplicação

```sh
flutter run
```

