import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:flutter_notification_channel/notification_visibility.dart';
import 'package:instagram_clone/Provider/post_card_provider.dart';
import 'package:instagram_clone/Provider/profile_screen_Provider.dart';
import 'package:instagram_clone/Provider/user_provider.dart';
import 'package:instagram_clone/Responsive/mobile_layout.dart';
import 'package:instagram_clone/Responsive/responsive_layout.dart';
import 'package:instagram_clone/Responsive/web_layout.dart';
import 'package:instagram_clone/Screens/Login_Screen.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/routes/routes.dart';
import 'package:provider/provider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  if(kIsWeb){
    await Firebase.initializeApp(
      options: FirebaseOptions(apiKey: "AIzaSyCAedWCeEqf2vrtqO5rIhSAbYhK9K4syqo",
          authDomain: "insta-clone-c33a7.firebaseapp.com",
          projectId: "insta-clone-c33a7",
          storageBucket: "insta-clone-c33a7.appspot.com",
          messagingSenderId: "723845533672",
          appId: "1:723845533672:web:bd393336456ec7aca61e5d")
    );
  }
  else{
    await Firebase.initializeApp();
  }
  var result = await FlutterNotificationChannel.registerNotificationChannel(
    description: 'Notications for chats',
    id: 'chats',
    importance: NotificationImportance.IMPORTANCE_HIGH,
    name: 'Chats',
    visibility: NotificationVisibility.VISIBILITY_PUBLIC,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_)=>UserProvider(),),
        ChangeNotifierProvider(create: (_)=>ProfileScreenProvider(),),
        ChangeNotifierProvider(create: (_)=>PostCardProvider(),),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: mobileBackgroundColor,
        ),
        onGenerateRoute: Routes.generateRoute,
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context,snapshot){
            if(snapshot.connectionState==ConnectionState.active){
              if(snapshot.hasData){
                //go to home
                return const ResponsiveLayout(mobileLayout: MobileLayout(), webLayout: WebLayout());
              }
              else if(snapshot.hasError){
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              }
            }
            if(snapshot.connectionState==ConnectionState.waiting){
              return const Center(
                child: CircularProgressIndicator(color: primaryColor,),
              );
            }
            return const LoginScreen();
          },
        ),

      ),
    );
  }
}

