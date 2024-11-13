import 'package:flutter/material.dart';
import 'package:smartcare/app_colors.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io'; // تأكد من إضافة هذا الاستيراد
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isSending = false;

  // متغير لحفظ الصورة المختارة
  XFile? _selectedImage;

  // قائمة الكلمات المفتاحية
  final List<String> _keywords = [
    'Track my request',
    'I need help',
    'I need maintenance',
    'I need Feedback',
    'Other'
  ];

  // لتحديد ما إذا تم اختيار كلمة مفتاحية
  bool _isKeywordSelected = false;

  // لتحديد ما إذا كان المستخدم يتابع طلبًا
  bool _isTrackingRequest = false;

  // رقم الطلب الذي يتم تتبعه
  String _trackingRequestNumber = '';

  // لتغيير hintText بناءً على حالة التطبيق
  String _inputHint = 'Type a message...';

  final String _apiKey =
      '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';

  // قائمة أرقام الطلبات الوهمية
  final List<String> _mockRequestNumbers = [
    '12345',
    '67890',
  ];

  Future<File?> _compressImage(File file) async {
    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      '${file.parent.path}/temp_${file.path.split('/').last}',
      quality: 50, // يمكنك تعديل الجودة حسب الحاجة (0-100)
      minWidth: 800, // العرض الأدنى للصورة بعد الضغط
      minHeight: 800, // الارتفاع الأدنى للصورة بعد الضغط
    );
    return compressedFile;
  }

  // متغيرات جديدة لإدارة مؤشر التحميل
  Timer? _loadingTimer;
  int? _loadingMessageIndex;
  List<String> _loadingDots = ['.', '..', '...'];
  int _currentDot = 0;

  @override
  void initState() {
    super.initState();
    // إضافة رسالة ترحيبية تلقائية
    _messages.add({'text': 'How can I assist you?', 'isUser': false});
  }

  @override
  void dispose() {
    _controller.dispose();
    _loadingTimer?.cancel();
    super.dispose();
  }

  Future<void> _sendMessage({String? text, XFile? image}) async {
    if ((text == null || text.isEmpty) && image == null) return;

    setState(() {
      if (text != null && text.isNotEmpty) {
        _messages.add({'text': text, 'isUser': true});
      }
      if (image != null) {
        _messages.add({'text': 'Sending image...', 'isUser': true});
      }
      // إضافة رسالة تحميل من الذكاء الاصطناعي
      _messages.add({
        'text': _loadingDots[_currentDot],
        'isUser': false,
        'isLoading': true
      });
      _loadingMessageIndex = _messages.length - 1;
      _isSending = true;
    });

    // بدء مؤقت لتحديث مؤشر التحميل
    _loadingTimer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      setState(() {
        _currentDot = (_currentDot + 1) % _loadingDots.length;
        if (_loadingMessageIndex != null) {
          _messages[_loadingMessageIndex!]['text'] = _loadingDots[_currentDot];
        }
      });
    });

    try {
      // إعداد الرسائل لإرسالها إلى API
      List<Map<String, dynamic>> chatMessages = List.from(_messages.map((msg) {
        if (msg['isUser']) {
          return {'role': 'user', 'content': msg['text']};
        } else {
          return {'role': 'assistant', 'content': msg['text']};
        }
      }));

      // إضافة الصورة إذا وجدت
      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64Image = base64Encode(bytes);
        chatMessages.add({
          'role': 'user',
          'content': "Image: data:image/png;base64,$base64Image"
        });
      }

      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {
              'role': 'system',
              'content': '''
انت خدمة عملاء لشركة روشن العقارية. مهمتك هي الرد على استفسارات العملاء المتعلقة بمشاكل العقارات والصور الخاصة بالعقارات فقط، بالإضافة إلى طلبات تتبع الطلبات. يجب عليك تقديم حلول فعّالة للمشاكل ورفع طلبات الشكاوى والاستفسارات إلى الأقسام المختصة. تأكد من التحدث بلغة مهذبة واحترافية، وكن مستمعًا جيدًا لمشاكل العملاء لضمان رضاهم التام.
**مهمة إضافية:** قم بالرد بنفس اللغة التي يتحدث بها المستخدم مثلاً لو ارسل Track my request قم بالاجابة بالانقليزي.

### **معلومات عن شركة روشن:**

#### **نحن روشن:**
- **الموقع العربي:** [www.roshn.sa/ar](http://www.roshn.sa/ar)
- **الموقع الإنجليزي:** [www.roshn.sa/en](http://www.roshn.sa/en)
- **رقم الدعم الفني الذكي:** +1 318 523 4059

#### **كلمات من القيادة:**
- **كلمة صاحب السمو الملكي الأمير محمد بن سلمان ولي العهد:**
  طموحنا أن نبني وطناً أكثر ازدهاراً، يجد فيه كل مواطن ما يتمناه، فمستقبل وطننا الذي نبنيه معاً، لن نقبل إلا أن نجعله في مقدمة دول العالم.

#### **عن روشن:**
- **مجموعة روشن المطور العقاري الرائد** متعدد الأصول في المملكة العربية السعودية، وإحدى شركات صندوق الاستثمارات العامة.
- **رؤيتنا:** تحقيق التناغم بين الإنسان والمكان بما ينسجم مع نمط الحياة العصري.
- **رسالتنا:** تطوير وجهات متكاملة تعزز من جودة الحياة وتثري الترابط بين الإنسان والمكان.
- **قيمنا:**
  - الإنسان أولاً
  - الريادة بتميز
  - العمل بمسؤولية
  - نلهم الأجيال
  - التنوع بتناغم
  - المسؤولية الاجتماعية

#### **تنوع مشاريعنا:**
1. **الأصول الأساسية:** المجتمعات السكنية، المكاتب التجارية، مراكز التجزئة، الفنادق والضيافة.
2. **الأصول الداعمة:** التعليم، المساجد، الرعاية الصحية.
3. **الأصول الواعدة:** النقل والخدمات اللوجستية، الرياضة، الترفيه.

#### **الجوائز والشهادات:**
- **أفضل بيئة عمل 2023** من منظمة Best Places to Work.
- **جوائز تجربة العملاء السعودية 2024:** فئة "العملاء أولاً" و "أفضل تجربة العملاء في قطاع العقار".
- **جوائز Middle East Construction Week 2022:** فئتا "أفضل مبادرة للمسؤولية الاجتماعية للشركات" و "أفضل مشروع سكني".
- **شهادات ISO 2023:** تشمل ISO 37000، ISO 31000، ISO 9001، ISO 10002، ISO 22301، ISO 27001، ISO 37101، ISO 37106، ISO 45001، ISO 10003، ISO 10004.

#### **مسؤوليتنا الاجتماعية:**
- **برنامج "يحييك":** يركز على تنمية المجتمع، الاستدامة البيئية، التعليم والابتكار، الفنون والثقافة، والصحة العامة.
- **مبادراتنا:** تساهم في رفع جودة الحياة وترك أثر إيجابي مستدام في المجتمع.

#### **مجتمعاتنا:**
- **سدرة، العروس، وارفة، المنار، الدانة، الفلوة:** مجتمعات سكنية متكاملة تلبي كافة احتياجات السكان من وحدات سكنية ومرافق وخدمات متنوعة.

#### **رؤية السعودية 2030:**
- **مساهمة روشن:** دعم برامج الإسكان الوطني، جودة الحياة، وصندوق الاستثمارات العامة لتحقيق أهداف رؤية السعودية 2030.

#### **روابط التواصل الاجتماعي:**
- [LinkedIn](https://www.linkedin.com/company/roshnksa)
- [X (Twitter)](https://x.com/roshnksa)
- [Instagram](https://www.instagram.com/roshnksa/)

#### **رقم الدعم الفني الذكي:**
- **+1 318 523 4059**

### **توجيهات إضافية:**

1. **التعامل مع الاستفسارات:**
   - **مشكلة في العقار:** اجمع المعلومات اللازمة مثل رقم الوحدة، موقع العقار، وطبيعة المشكلة. قدم حلاً أو اشرح الخطوات التالية.
   - **طلب صور للعقار:** زوّد العميل بالصور المطلوبة أو ارشده إلى القسم المختص.
   - **تتبع الطلب:** عندما يطلب العميل تتبع طلب برقم معين، تحقق مما إذا كان الرقم موجودًا في بياناتك الوهمية وقدم التفاصيل المناسبة.
### **بيانات تتبع الطلبات الوهمية:**
- **طلب رقم 12345:**
  - **الحالة:** قيد المعالجة
  - **التاريخ المتوقع للانتهاء:** 2024-12-15
  - **الوصف:** طلب صيانة لمشكلة تسرب المياه في الوحدة رقم 45 في مجتمع سدرة.

- **طلب رقم 67890:**
  - **الحالة:** مكتمل
  - **التاريخ:** 2024-11-10
  - **الوصف:** طلب تتبع دفع الإيجار للوحدة رقم 12 في مجتمع العروس.

### **مثال على الرد:**

**سؤال العميل:**
"Track my request 12345"

**رد خدمة العملاء:**
"شكرًا لتواصلك مع روشن. حالة طلبك رقم 12345 هي قيد المعالجة، والتاريخ المتوقع للانتهاء هو 2024-12-15. سيتم إرسال فريق الصيانة المختص إلى وحدتك رقم 45 في مجتمع سدرة لحل مشكلة تسرب المياه. إذا كان لديك أي استفسارات إضافية، لا تتردد في الاتصال بنا على الرقم الذكي +1 318 523 4059."
'''
            },
            ...chatMessages,
          ],
        }),
      );

      print(chatMessages);

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));

        final aiResponse = data['choices'] != null && data['choices'].isNotEmpty
            ? data['choices'][0]['message']['content']
            : 'No response from AI';

        setState(() {
          if (_loadingMessageIndex != null) {
            _messages[_loadingMessageIndex!]['text'] = aiResponse;
            _messages[_loadingMessageIndex!].remove('isLoading');
            _loadingMessageIndex = null;
          } else {
            _messages.add({'text': aiResponse, 'isUser': false});
          }
        });
      } else {
        print(response.body);
        setState(() {
          if (_loadingMessageIndex != null) {
            _messages[_loadingMessageIndex!]['text'] =
                'Error fetching response';
            _messages[_loadingMessageIndex!].remove('isLoading');
            _loadingMessageIndex = null;
          } else {
            _messages.add({'text': 'Error fetching response', 'isUser': false});
          }
        });
      }
    } catch (e) {
      setState(() {
        if (_loadingMessageIndex != null) {
          _messages[_loadingMessageIndex!]['text'] = 'Failed to send message';
          _messages[_loadingMessageIndex!].remove('isLoading');
          _loadingMessageIndex = null;
        } else {
          _messages.add({'text': 'Failed to send message', 'isUser': false});
        }
      });
    } finally {
      setState(() {
        _isSending = false;
        _selectedImage = null;
      });
      // إيقاف المؤقت بعد الانتهاء
      _loadingTimer?.cancel();
      _loadingTimer = null;
      _currentDot = 0;
    }
  }

  Future<void> _handleSend() async {
    if (_isTrackingRequest) {
      // إذا كان المستخدم يتابع طلبًا، تأكد من إدخال رقم الطلب
      if (_controller.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter your request number.')),
        );
        return;
      }
      _trackingRequestNumber = _controller.text;
      setState(() {
        _isTrackingRequest = false;
        _inputHint = 'Type a message...';
      });
      // إرسال رسالة تتبع الطلب مع رقم الطلب
      String trackMessage = 'Track my request $_trackingRequestNumber';
      await _sendMessage(text: trackMessage);
      _controller.clear();
      return;
    }
    await _sendMessage(text: _controller.text, image: _selectedImage);
    _controller.clear();
  }

  Future<void> _handleSendImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    File imageFile = File(image.path);

    // ضغط الصورة
    File? compressedImage = await _compressImage(imageFile);

    if (compressedImage != null) {
      setState(() {
        _selectedImage = XFile(compressedImage.path);
      });
      await _sendMessage(image: _selectedImage);
    } else {
      // إذا فشل الضغط، استخدم الصورة الأصلية
      setState(() {
        _selectedImage = image;
      });
      await _sendMessage(image: _selectedImage);
    }
  }

  // دالة لحذف الصورة المختارة
  void _removeSelectedImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  // دالة لمعالجة اختيار الكلمة المفتاحية
  Future<void> _handleKeywordSelection(String keyword) async {
    if (keyword == 'Track my request') {
      // عرض مربع اختيار رقم الطلب من الأرقام الوهمية
      String? selectedNumber = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Select Request Number'),
            content: Container(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _mockRequestNumbers.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(_mockRequestNumbers[index]),
                    onTap: () {
                      Navigator.of(context).pop(_mockRequestNumbers[index]);
                    },
                  );
                },
              ),
            ),
          );
        },
      );

      if (selectedNumber != null) {
        setState(() {
          _isKeywordSelected = true;
          _isTrackingRequest = true;
          _inputHint = 'Enter your request number...';
          // إضافة رسالة توضيحية في الدردشة
          _messages.add({
            'text': 'Tracking request number: $selectedNumber',
            'isUser': true
          });
        });
        // إرسال رسالة تتبع الطلب مع رقم الطلب
        String trackMessage = 'Track my request $selectedNumber';
        await _sendMessage(text: trackMessage);
      }
    } else {
      setState(() {
        _isKeywordSelected = true;
      });
      await _sendMessage(text: keyword);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Report a Problem',
          style: TextStyle(
            color: AppColors.subtitleColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(
          color: AppColors.iconColor,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            // عرض الصورة المختارة إذا وجدت
            if (_selectedImage != null)
              Container(
                padding: EdgeInsets.all(8.0),
                child: Stack(
                  children: [
                    Image.file(
                      File(_selectedImage!.path),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      right: -10,
                      top: -10,
                      child: IconButton(
                        icon: Icon(Icons.close, color: Colors.red),
                        onPressed: _removeSelectedImage,
                      ),
                    ),
                  ],
                ),
              ),
            // عرض قائمة الرسائل
            Expanded(
              child: ListView.builder(
                reverse: false,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isUser = message['isUser'] as bool;
                  final isLoading = message['isLoading'] ?? false;
                  return Row(
                    mainAxisAlignment: isUser
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      if (!isUser)
                        Image.asset(
                          'assets/chatbot_svgrepo.png',
                          width: 40,
                        ),
                      Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        padding: EdgeInsets.all(12),
                        constraints: BoxConstraints(maxWidth: 250),
                        decoration: BoxDecoration(
                          color: isUser
                              ? Color(0xFF4C837A).withOpacity(0.3)
                              : Color(0xFFB0B0B0).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: isLoading
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    message['text'],
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ],
                              )
                            : message['text']
                                    .toString()
                                    .startsWith('data:image')
                                ? Image.memory(
                                    base64Decode(
                                      message['text']
                                          .toString()
                                          .split('base64,')[1],
                                    ),
                                    width: 150,
                                    height: 150,
                                  )
                                : Text(
                                    message['text'],
                                    style: TextStyle(color: Colors.black),
                                  ),
                      ),
                    ],
                  );
                },
              ),
            ),
            // عرض كلمات مفتاحية إذا لم يتم اختيار أي كلمة بعد أو في حالة تتبع طلب
            if (!_isKeywordSelected || _isTrackingRequest)
              Container(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _keywords.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: ChoiceChip(
                        label: Text(_keywords[index]),
                        selected: false,
                        onSelected: (_) {
                          _handleKeywordSelection(_keywords[index]);
                        },
                        backgroundColor: Color(0xffC3CE28).withOpacity(0.3),
                        selectedColor: Colors.blue[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          side: BorderSide(color: Colors.transparent),
                        ),
                      ),
                    );
                  },
                ),
              ),
            // عرض TextField بناءً على حالة التطبيق
            if (_isTrackingRequest)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: _inputHint,
                          filled: true,
                          fillColor: Colors.grey[200], // خلفية رصاصية
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none, // إزالة الحدود
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: _isSending ? null : _handleSend,
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: EdgeInsets.all(8.0),
                child: TextField(
                  controller: _controller,
                  enabled: _isKeywordSelected && !_isTrackingRequest,
                  decoration: InputDecoration(
                    hintText: _inputHint,
                    filled: true,
                    fillColor: Colors.grey[200], // خلفية رصاصية
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none, // إزالة الحدود
                    ),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min, // لضمان عدم توسع الصف
                      children: [
                        IconButton(
                          icon: Icon(Icons.photo),
                          onPressed: _handleSendImage,
                        ),
                        IconButton(
                          icon: Icon(Icons.send),
                          onPressed: _isSending ? null : _handleSend,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
