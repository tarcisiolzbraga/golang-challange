# Etapa 1: Build da aplicação
FROM golang:1.24.3-alpine AS builder

# Instala a ferramenta UPX (Ultimate Packer for eXecutables), que será usada para compactar o binário
RUN apk add --no-cache upx

# Define o diretório de trabalho dentro da imagem Docker
WORKDIR /app

# Cria um arquivo main.go simples"
COPY <<EOF main.go
package main
import "fmt"
func main() {
    fmt.Println("Fullcycle ROCKS!")
}
EOF

# Compila o código Go com flags para reduzir o tamanho do binário
# (-s remove a tabela de símbolos, -w remove informações de debug)
# Em seguida, usa o UPX para compactar o binário com a melhor taxa de compressão (lzma)
RUN go build -ldflags="-s -w" -o fcrocks main.go && \
    upx --best --lzma fcrocks

# Etapa 2: Imagem mínima com 'scratch'
# 'scratch' é uma imagem vazia, sem sistema operacional ou pacotes adicionais
FROM scratch

# Copia o binário 'fcrocks' da etapa anterior para a nova imagem
COPY --from=builder /app/fcrocks /fcrocks

# Define o binário 'fcrocks' como o ponto de entrada do contêiner
ENTRYPOINT ["/fcrocks"]