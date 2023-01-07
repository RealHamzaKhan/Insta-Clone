import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:instagram_clone/resources/auth_methods.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/routes/routes_names.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:instagram_clone/widgets/CustomButton.dart';
import 'package:instagram_clone/widgets/textformfield.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  void login()async{
    setState(() {
      isLoading=true;
    });
    String res=await AuthMethods().loginUser(email: emailController.text, password: passwordController.text);
    if(res=='success'){
      Navigator.pushNamed(context, RoutesNames.responsivelayout);
      //login successfully
      setState(() {
        isLoading=false;
      });
    }
    else{
      //login failed
      Utils().showSnackBar(context,res, Colors.red);
      setState(() {
        isLoading=false;
      });
    }
  }
  final emailController=TextEditingController();
  final passwordController=TextEditingController();
  bool isLoading=false;
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    // TODO: implement dispose
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final height=MediaQuery.of(context).size.height*1;
    final width=MediaQuery.of(context).size.width*1;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset('assets/ic_instagram.svg',
                height: height*0.3,
                  width: double.infinity,
                  color: primaryColor,
                ),
                SizedBox(height: height*0.06,),
                CustomTextFormField(controller: emailController, hintText: 'Email', isPassword: false),
                SizedBox(height: height*0.04,),
                CustomTextFormField(controller: passwordController, hintText: 'Password', isPassword: true),
                SizedBox(height: height*0.04,),
                CustomButton(title: 'Login', onPressAction: (){
                   login();
                }, isLoading: isLoading),
                SizedBox(height: height*0.08,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Dont have an account?'),
                    TextButton(onPressed: (){
                      Navigator.pushNamed(context, RoutesNames.signupScreen);
                    }, child:Text('SignUp',style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold
                    ),)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
