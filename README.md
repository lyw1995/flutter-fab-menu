# fab_menu

A FabMenu widget Demo for Flutter.

![screenshot](/screenshot/fabmenu.gif)

## Demo
```
import 'package:flutter/material.dart';
  import 'fab_menu.dart';
  void main() => runApp(FabMenuDemo());
  
  class FabMenuDemo extends StatelessWidget {
  
    @override
    Widget build(BuildContext context) {
      return  MaterialApp(
        home:   Scaffold(
          appBar: AppBar(
            title: Text("FabMenu Demo"),
          ),
          body: Row(
            children: <Widget>[
              Expanded(
                child: FabMenu()
                    .setLocation(MenuLocation.BottomLeft) // location: bleft or bright
                    .addCenterFab(Icons.menu) // must has center button
                    .addActionFab(Icons.phone) 
                    .addActionFab(Icons.email)
                    .addActionFab(Icons.location_on),
              ),
              Expanded(
                child: FabMenu()
                    .addCenterFab(Icons.menu)
                    .addActionFab(Icons.phone)
                    .addActionFab(Icons.email)
                    .addActionFab(Icons.location_on),
              ),
            ],
          ),
        ),
      );
    }
  }
  ```

