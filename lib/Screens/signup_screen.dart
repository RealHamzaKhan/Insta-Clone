import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/resources/auth_methods.dart';
import 'package:instagram_clone/utils/routes/routes_names.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/widgets/CustomButton.dart';
import 'package:instagram_clone/widgets/textformfield.dart';
class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  void signUp()async{
    setState(() {
      isLoading=true;
    });
    String res=await AuthMethods().signUp(
        username: usernamecontroller.text,
        email: emailController.text,
        password: passwordController.text,
        bio: biocontroller.text,
        file: image!);
    if(res=='success'){
      setState(() {
        isLoading=false;
      });
      Utils().showSnackBar(context, 'SignUp Successful',Colors.green);
      Navigator.pushNamed(context, RoutesNames.responsivelayout);
      //Signup succefull
    }
    else{
      setState(() {
        isLoading=false;
      });
      Utils().showSnackBar(context, res,Colors.red);
      //error occured
    }
  }
  void selectImage()async{
    Uint8List im=await Utils().pickImage(ImageSource.gallery);
    setState(() {
      image=im;
    });
  }
  Uint8List? image;
  final emailController=TextEditingController();
  final passwordController=TextEditingController();
  final usernamecontroller=TextEditingController();
  final biocontroller=TextEditingController();
  bool isLoading=false;
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    usernamecontroller.dispose();
    biocontroller.dispose();
    // TODO: implement dispose
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final height=MediaQuery.of(context).size.height*1;
    final width=MediaQuery.of(context).size.width*1;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset('assets/ic_instagram.svg',
                    height: height*0.1,
                    width: double.infinity,
                    color: primaryColor,
                  ),
                  SizedBox(height: height*0.06,),
                  Stack(
                    children: [
                      image==null?
                      CircleAvatar(
                        radius: 70,
                        backgroundImage: NetworkImage('https://as2.ftcdn.net/v2/jpg/02/15/84/43/1000_F_215844325_ttX9YiIIyeaR7Ne6EaLLjMAmy4GvPC69.jpg'),
                      )
                      :
                      CircleAvatar(
                        radius: 70,
                        backgroundImage: MemoryImage(image!),
                      ),
                      Positioned(
                          bottom: 10,
                          right: 5,
                          child: GestureDetector(
                              onTap: (){
                                selectImage();
                              },
                              child: Icon(Icons.camera_alt,color: primaryColor,))),
                    ],
                  ),
                  SizedBox(height: height*0.04,),
                  CustomTextFormField(controller: usernamecontroller, hintText: 'Username', isPassword: false),
                  SizedBox(height: height*0.04,),
                  CustomTextFormField(controller: emailController, hintText: 'Email', isPassword: false),
                  SizedBox(height: height*0.04,),
                  CustomTextFormField(controller: passwordController, hintText: 'Password', isPassword: true),
                  SizedBox(height: height*0.04,),
                  CustomTextFormField(controller: biocontroller, hintText: 'Bio', isPassword: false,maxlines: 4,),
                  SizedBox(height: height*0.04,),
                  CustomButton(title: 'Signup', onPressAction: (){
                    if(image==null){
                      setState(() {
                        isLoading=false;
                      });
                      //image is null
                      Utils().showSnackBar(context,'Kindly upload an image', Colors.red);
                    }
                    else{
                      signUp();
                    }

                  }, isLoading: isLoading),
                  SizedBox(height: height*0.02,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Dont have an account?'),
                      TextButton(onPressed: (){
                        Navigator.pushNamed(context, RoutesNames.loginScreen);
                      }, child:Text('Login',style: TextStyle(
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
      ),
    );
  }
}
