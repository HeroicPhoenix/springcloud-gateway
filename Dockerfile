# =========================
# 1) Build stage: build jar
# =========================
FROM maven:3.8.8-eclipse-temurin-8 AS builder
WORKDIR /workspace

# 先拷贝 pom.xml 利用缓存
COPY pom.xml .
RUN mvn -q -e -DskipTests dependency:go-offline

# 再拷贝源码（包含 src/main/resources）并编译
COPY src ./src
RUN mvn -q -DskipTests package


# =========================
# 2) Runtime stage
#    ✅ 轻量 JRE8 运行环境
# =========================
FROM eclipse-temurin:8-jre
WORKDIR /app

# （可选）容器时区
ENV TZ=Asia/Shanghai

# 拷贝 jar（容器内统一叫 app.jar）
COPY --from=builder /workspace/target/*.jar /app/app.jar

# gateway 默认端口（你 yml 配的 server.port）
EXPOSE 8080

ENTRYPOINT ["java","-jar","/app/app.jar"]