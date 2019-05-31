// import 'dart:async';

// import 'package:flutter/material.dart';

// const SPLASH_DURATION = 3000;

// class SplashScreen extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() {
//     return SplashState();
//   }
// }

// class SplashState extends State<SplashScreen> with TickerProviderStateMixin {
//   AnimationController _controller;

//   @override
//   void initState() {
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: SPLASH_DURATION),
//       vsync: this,
//     );
//     _controller.forward();
//     Future.delayed(const Duration(milliseconds: SPLASH_DURATION), () {
//       Navigator.pushReplacementNamed(context, '/home');
//     });
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: AnimatedComponent(
//         controller: _controller.view,
//       ),
//     );
//   }
// }

// class AnimatedComponent extends StatelessWidget {
//   AnimatedComponent({Key key, this.controller})
//       : ticker = Tween<double>(
//           begin: 0.0,
//           end: 1.0,
//         ).animate(
//           CurvedAnimation(
//             parent: controller,
//             curve: Interval(
//               0.0,
//               0.7,
//               curve: Curves.ease,
//             ),
//           ),
//         ),
//         super(key: key);

//   final Animation<double> controller;
//   final Animation<double> ticker;

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       builder: _buildAnimation,
//       animation: controller,
//     );
//   }

//   Widget _buildAnimation(BuildContext context, Widget child) {
//     double width = MediaQuery.of(context).size.width / 2;
//     double logoOffset = MediaQuery.of(context).size.height / 3.5;

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Stack(
//         fit: StackFit.expand,
//         children: <Widget>[
//           Container(
//             decoration: BoxDecoration(
//               image: DecorationImage(
//                 fit: BoxFit.fitWidth,
//                 image: AssetImage('images/splash/splash_bg.jpg'),
//               ),
//             ),
//             child: Container(
//               margin: EdgeInsets.only(bottom: logoOffset),
//               child: Center(
//                 child: Transform.scale(
//                   scale: ticker.value,
//                   child: Opacity(
//                     opacity: ticker.value,
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: <Widget>[
//                         SizedBox.fromSize(
//                           child: Image.asset('images/splash/splash.png'),
//                           size: Size(width, 50),
//                         ),
//                         Text(
//                           'Bringing dreams to life',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             color: AppColorScheme.secondary,
//                             fontSize: 17,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
