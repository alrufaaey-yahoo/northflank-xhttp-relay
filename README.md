<div align="center">

# 🔁 Northflank XHTTP Relay

<img src="https://img.shields.io/badge/Node.js-18+-339933?style=for-the-badge&logo=node.js&logoColor=white" />
<img src="https://img.shields.io/badge/Northflank-Deploy-4C51BF?style=for-the-badge&logo=docker&logoColor=white" />
<img src="https://img.shields.io/badge/Docker-Ready-2496ED?style=for-the-badge&logo=docker&logoColor=white" />
<img src="https://img.shields.io/badge/XHTTP-Relay-blue?style=for-the-badge" />

**ريلاي XHTTP خفيف وسريع يعمل على Northflank — يقوم بتوجيه الطلبات إلى سيرفرك الخاص (VPS) عبر بروكسي عكسي.**

---

</div>

## 📋 الوصف

هذا المشروع عبارة عن **Reverse Proxy Relay** مبني بـ Node.js، مصمم للعمل على منصة **Northflank** كوسيط بين العميل والسيرفر الهدف. يقوم بتمرير جميع الطلبات (GET, POST, PUT, DELETE, etc.) إلى الدومين المستهدف مع تنظيف الهيدرز غير الضرورية للحفاظ على الخصوصية والأمان.

## ✨ المميزات

| الميزة | الوصف |
|--------|-------|
| 🚀 **خفيف وسريع** | لا يحتاج أي مكتبات خارجية — يعمل بـ Node.js الأساسي فقط |
| 🐳 **Docker Ready** | يحتوي على Dockerfile جاهز للبناء والنشر |
| 🔒 **تنظيف الهيدرز** | يزيل تلقائياً الهيدرز الحساسة والمكشوفة |
| 🌐 **دعم HTTP/HTTPS** | يدعم التوجيه لكلا البروتوكولين |
| 📡 **Streaming** | يدعم تمرير البيانات بالـ Stream للأداء العالي |
| ⚙️ **Environment Variables** | يدعم ضبط الإعدادات عبر متغيرات البيئة |
| ☁️ **جاهز للنشر** | مُعد مسبقاً للنشر على Northflank بضغطة زر |

## ⚠️ إعداد مهم — تعديل الدومين المستهدف

> **يجب عليك ضبط متغير البيئة `TARGET_DOMAIN` في إعدادات Northflank ليشير إلى سيرفرك الخاص (VPS).**

مثال:

```
TARGET_DOMAIN=https://123.456.789.0:443
```

أو باستخدام دومين:

```
TARGET_DOMAIN=https://mydomain.com:443
```

## 🚀 طريقة النشر على Northflank

### الطريقة 1: النشر بضغطة واحدة عبر Template (مُوصى بها)

> هذه أسهل وأسرع طريقة — تنشئ المشروع والخدمة والمنفذ تلقائياً.

1. سجل الدخول إلى [Northflank](https://app.northflank.com)
2. اربط حساب GitHub من **Account** → **Git** → **GitHub**
3. اذهب إلى **Templates** من القائمة الجانبية
4. اضغط **Create template** → اختر **Code** (أيقونة `<>`)
5. **احذف أي محتوى موجود** والصق كود الـ Template التالي بالكامل:

<details>
<summary>📋 اضغط هنا لعرض كود الـ Template</summary>

```json
{
  "apiVersion": "v1.2",
  "name": "XHTTP Relay",
  "description": "Deploy XHTTP Relay proxy to forward requests to your VPS target domain.",
  "arguments": {
    "TARGET_DOMAIN": {
      "type": "string",
      "description": "Your VPS target domain (e.g. https://yourvps:443)",
      "default": "https://yourvps:443",
      "required": true
    }
  },
  "spec": {
    "kind": "Workflow",
    "spec": {
      "type": "sequential",
      "steps": [
        {
          "kind": "Project",
          "ref": "project",
          "spec": {
            "name": "xhttp-relay",
            "description": "XHTTP Relay Proxy Service",
            "region": "europe-west"
          }
        },
        {
          "kind": "Workflow",
          "spec": {
            "type": "sequential",
            "context": {
              "projectId": "${refs.project.id}"
            },
            "steps": [
              {
                "kind": "SecretGroup",
                "spec": {
                  "type": "secret",
                  "secretType": "environment-arguments",
                  "priority": 10,
                  "secrets": {
                    "variables": {
                      "TARGET_DOMAIN": "${args.TARGET_DOMAIN}",
                      "PORT": "3000"
                    },
                    "files": {}
                  },
                  "name": "relay-env",
                  "restrictions": {
                    "restricted": false,
                    "nfObjects": [],
                    "tags": []
                  }
                },
                "ref": "relay-env"
              },
              {
                "kind": "CombinedService",
                "spec": {
                  "deployment": {
                    "instances": 1,
                    "storage": {
                      "ephemeralStorage": {
                        "storageSize": 1024
                      },
                      "shmSize": 64
                    },
                    "docker": {
                      "configType": "default"
                    }
                  },
                  "runtimeEnvironment": {},
                  "runtimeFiles": {},
                  "buildArguments": {},
                  "buildFiles": {},
                  "billing": {
                    "deploymentPlan": "nf-compute-10",
                    "buildPlan": "nf-compute-400-16"
                  },
                  "name": "xhttp-relay",
                  "vcsData": {
                    "projectType": "github",
                    "accountLogin": "alrufaaey-yahoo",
                    "projectUrl": "https://github.com/alrufaaey-yahoo/northflank-xhttp-relay",
                    "projectBranch": "master"
                  },
                  "ports": [
                    {
                      "internalPort": 3000,
                      "protocol": "HTTP",
                      "name": "p01",
                      "public": true,
                      "domains": [],
                      "security": {
                        "policies": [],
                        "credentials": []
                      },
                      "disableNfDomain": false
                    }
                  ],
                  "buildSettings": {
                    "dockerfile": {
                      "buildEngine": "kaniko",
                      "useCache": false,
                      "dockerWorkDir": "/",
                      "dockerFilePath": "/Dockerfile",
                      "buildkit": {
                        "useInternalCache": false,
                        "internalCacheStorage": 16384
                      }
                    }
                  },
                  "disabledCI": false,
                  "buildConfiguration": {
                    "pathIgnoreRules": [],
                    "isAllowList": false,
                    "ciIgnoreFlagsEnabled": false
                  }
                },
                "ref": "xhttp-relay-service"
              },
              {
                "kind": "Condition",
                "spec": {
                  "kind": "Service",
                  "spec": {
                    "data": {
                      "serviceId": "${refs.xhttp-relay-service.id}"
                    },
                    "type": "running"
                  }
                }
              }
            ]
          }
        }
      ]
    }
  }
}
```

</details>

6. اضغط **Save** لحفظ الـ Template
7. اضغط **Run template**
8. عند سؤالك عن `TARGET_DOMAIN`، أدخل عنوان سيرفرك:
   ```
   https://yourvps:443
   ```
   ⚠️ **استبدل `yourvps` بعنوان IP أو دومين سيرفرك الخاص**
9. اضغط **Run** وانتظر حتى يكتمل النشر
10. بعد الاكتمال، اذهب للمشروع → الخدمة → **Ports** للحصول على الرابط العام

---

### الطريقة 2: النشر اليدوي خطوة بخطوة

#### الخطوة 1: ربط GitHub مع Northflank
1. سجل الدخول إلى [Northflank](https://app.northflank.com)
2. اذهب إلى **Account** → **Git** → **GitHub**
3. اربط حساب GitHub الخاص بك

#### الخطوة 2: إنشاء مشروع جديد
1. اضغط **Create new project**
2. اختر اسماً للمشروع (مثلاً: `xhttp-relay`)

#### الخطوة 3: إنشاء Service
1. داخل المشروع، اضغط **Add new service** → **Combined service**
2. اختر **Git repository** → حدد هذا المستودع `northflank-xhttp-relay`
3. في **Build settings**:
   - **Build type**: `Dockerfile`
   - **Dockerfile path**: `./Dockerfile`
4. في **Environment variables** أضف:
   ```
   TARGET_DOMAIN = https://yourvps:443
   ```
   ⚠️ **استبدل `yourvps` بعنوان سيرفرك الخاص**
5. في **Ports**:
   - **Port name**: `http`
   - **Internal port**: `3000`
   - **Protocol**: `HTTP`
   - **Public**: ✅ مفعّل
6. اضغط **Create service**

#### الخطوة 4: الحصول على الرابط
بعد اكتمال البناء والنشر، ستجد الرابط العام في قسم **Ports** بصيغة:
```
https://xhttp-relay--xxxxx.addon.code.run
```

## 📁 هيكل المشروع

```
northflank-xhttp-relay/
├── index.js          # الخادم الرئيسي — الريلاي
├── package.json      # إعدادات المشروع
├── Dockerfile        # ملف Docker للبناء على Northflank
├── northflank.json   # كود Template للنشر التلقائي
├── .dockerignore     # الملفات المستثناة من Docker
└── README.md         # هذا الملف
```

## 🔧 كيف يعمل

```
العميل  ──►  Northflank Relay  ──►  السيرفر الهدف (VPS)
  ◄──            ◄──                    ◄──
```

1. يستقبل الريلاي الطلب من العميل
2. ينظف الهيدرز الحساسة (مثل `host`, `x-forwarded-*`, `proxy-*`)
3. يمرر الطلب إلى `TARGET_DOMAIN`
4. يعيد الاستجابة من السيرفر الهدف إلى العميل

### الهيدرز المحذوفة تلقائياً

| Header | السبب |
|--------|-------|
| `host` | يُستبدل بدومين الهدف |
| `connection` / `keep-alive` | هيدرز اتصال غير ضرورية |
| `proxy-*` | هيدرز بروكسي مكشوفة |
| `x-forwarded-*` | تمنع تسريب معلومات الشبكة |
| `transfer-encoding` | يُعاد ضبطه تلقائياً |
| `x-northflank-*` | هيدرز خاصة بالمنصة |

## 🌍 متغيرات البيئة

| المتغير | الوصف | القيمة الافتراضية |
|---------|-------|-------------------|
| `TARGET_DOMAIN` | عنوان السيرفر الهدف (VPS) | `https://yourvps:443` |
| `PORT` | منفذ تشغيل الخادم | `3000` |

## 📝 ملاحظات

- تأكد من أن سيرفرك الهدف يقبل الاتصالات الخارجية
- Northflank يوفر طبقة مجانية (Free Tier) مناسبة للتجربة
- المشروع لا يحتاج أي `npm install` — يعمل بمكتبات Node.js الأساسية فقط
- يمكنك تفعيل **Auto-deploy** لينشر تلقائياً عند كل push جديد

---

<div align="center">

## 👨‍💻 المطور

**تم التطوير بواسطة الرفاعي**

[![Telegram](https://img.shields.io/badge/Telegram-@alrufaaey-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white)](https://t.me/alrufaaey)

---

<sub>إذا أعجبك المشروع، لا تنسَ ⭐ على GitHub</sub>

</div>
