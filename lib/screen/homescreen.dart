import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:upi_india/upi_india.dart';
import 'package:upi_india/upi_response.dart';

class HomeScreenPage extends StatefulWidget {
  const HomeScreenPage({Key? key}) : super(key: key);

  @override
  State<HomeScreenPage> createState() => _HomeScreenPageState();
}

class _HomeScreenPageState extends State<HomeScreenPage> {
  Future<UpiResponse>? _transaction;
  UpiIndia _upiIndia = UpiIndia();
  List<UpiApp>? apps;
 bool val=false;
TextEditingController amount = TextEditingController();
  Map<UpiApp, bool> maps = {};


  @override
  void initState(){
    _upiIndia.getAllUpiApps(
      mandatoryTransactionId: false,
    ).then((value){
      setState((){
        apps=value;
      });
    }).catchError((e){
      apps=[];
    });
    super.initState();
  }
  Future<UpiResponse> initateTransaction(UpiApp app) async {
    return _upiIndia.startTransaction(
        app: app,
        receiverUpiId: "shashikha1000@okaxis",
        receiverName: "Shashi Kha",
        transactionRefId: "TestingUpiIndiaPlugin",
      amount: double.parse(amount.text),
    );
  }
  Widget displayApps(){
    if(apps == null){
      return CircularProgressIndicator();
    } else if(apps!.length==0){
      return Center(
        child: Text("No apps found",),
      );

    } else return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
           Wrap(
              children: apps!.map((UpiApp app){
                return
                  CheckboxListTile(
                    tristate: true,
                    title: Text(app.name),
                    secondary: Image.memory(app.icon),
                    value:maps[app] ,
                    onChanged: (bool? value) {
                      setState((){
                        this.maps[app]=value!;
                      });
                    },



                    // child: Container(
                    //   height: 100,
                    //   width: 100,
                    //   child: Column(
                    //     mainAxisSize: MainAxisSize.min,
                    //     mainAxisAlignment: MainAxisAlignment.center,
                    //     children: [
                    //       Image.memory(
                    //         app.icon,
                    //         height: 60,
                    //         width: 60,
                    //       ),
                    //       Text(app.name),
                    //     ],
                    //   ),
                    // ),
                  );


              }).toList(),

            ),
            // ElevatedButton(onPressed: (){
            //   _transaction=initateTransaction(apps);
            // },
            //     child: Text("Proceed to checkout"))

          ],

        ),
      ),
    );
  }
  String _upiErrorHandler(error){
    switch (error) {
      case UpiIndiaAppNotInstalledException:
        return 'Requested app not installed on device';
      case UpiIndiaUserCancelledException:
        return 'You cancelled the transaction';
      case UpiIndiaNullResponseException:
        return 'Requested app didn\'t return any response';
      case UpiIndiaInvalidParametersException:
        return 'Requested app cannot handle the transaction';
      default:
        return 'An Unknown error has occurred';
    }
    }

  void _checkTxnStatus(String status) {
    switch (status) {
      case UpiPaymentStatus.SUCCESS:
        print('Transaction Successful');
        break;
      case UpiPaymentStatus.SUBMITTED:
        print('Transaction Submitted');
        break;
      case UpiPaymentStatus.FAILURE:
        print('Transaction Failed');
        break;
      default:
        print('Received an Unknown transaction status');
    }
  }
  Widget displayTransactionData(title,body){
    return Padding(
        padding: EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$title:"),
          Flexible(
              child: Text(body))
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Upi"),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: TextField(
              controller: amount,
              decoration: InputDecoration(
                hintText: "Enter the amount"
              ),
            ),
          ),
          Expanded(child: displayApps()),
          Expanded(
              child: FutureBuilder(
                future: _transaction,
                  builder: (context,AsyncSnapshot<UpiResponse> snapshot){
    if(snapshot.connectionState==ConnectionState.done){
    if(snapshot.hasError){
    return Center(
    child: Text(_upiErrorHandler(snapshot.error.runtimeType),)
    );
    }

    UpiResponse _upiResponse = snapshot.data!;
    String txnId = _upiResponse.transactionId ?? 'N/A';
    String resCode = _upiResponse.responseCode ?? 'N/A';
    String txnRef = _upiResponse.transactionRefId ?? 'N/A';
    String status = _upiResponse.status ?? 'N/A';
    String approvalRef = _upiResponse.approvalRefNo ?? 'N/A';
    _checkTxnStatus(status);

    return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
    displayTransactionData('Transaction Id', txnId),
    displayTransactionData('Response Code', resCode),
    displayTransactionData('Reference Id', txnRef),
    displayTransactionData('Status', status.toUpperCase()),
    displayTransactionData('Approval No', approvalRef),
    ],
    ),
    );

    }
    else return Center(
    child: Text(''),
    );
    }),
          )

        ],
      ),

    );
  }
}
