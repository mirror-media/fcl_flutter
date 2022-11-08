package com.mirrormedia.fcl_flutter



import android.app.Activity
import android.content.Context
import com.nftco.flow.sdk.FlowAccount
import com.nftco.flow.sdk.FlowAddress
import com.nftco.flow.sdk.FlowArgument
import com.nftco.flow.sdk.bytesToHex
import com.nftco.flow.sdk.cadence.Field
import com.portto.fcl.Fcl
import com.portto.fcl.config.AppDetail
import com.portto.fcl.config.Config
import com.portto.fcl.config.Network
import com.portto.fcl.model.authn.AccountProofResolvedData
import com.portto.fcl.provider.blocto.Blocto
import com.portto.fcl.utils.AppUtils
import io.flutter.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlin.random.Random


/** FclFlutterPlugin */
class FclFlutterPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private val mainScope = CoroutineScope(Dispatchers.Main)
  private var activity: Activity? = null
  private lateinit var context: Context

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "fcl_flutter")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    mainScope.launch {
      when(call.method){
        "initFCL" -> {
          initFCL(call.argument<String>("bloctoAppId")!!,call.argument<Boolean>("useTestNet")!!)
          result.success("Initial success")
        }
        "simpleLogin" -> {
          val accountAddress: String = simpleLogin()
          if(accountAddress != "error"){
            result.success(accountAddress)
          }else{
            result.error("SimpleLoginFailed", "Get user account address failed",null)
          }
        }
        "accountProofLogin" ->  {
          val accountAddress: String = accountProofLogin(call.argument<String>("appIdentifier")!!)
          if(accountAddress != "error"){
            result.success(accountAddress)
          }else{
            result.error("AccountProofLoginFailed", "Get user account address failed",null)
          }
        }
        "verifyAccountProof" -> if(Fcl.currentUser?.accountProofData == null){
          result.error("NoAccountProofData", "AccountProofData is null, accountProofLogin first",null)
        }else{
          val isValid :Boolean? = verifyAccountProof(call.argument<String>("appIdentifier")!!)
          if(isValid != null){
            result.success(isValid)
          }else{
            result.error("VerifyAccountProofFailed", "Verify accountProof failed",null)
          }
        }
        "getAddress" -> result.success(Fcl.currentUser?.address)
        "unauthenticate" -> {
          Fcl.unauthenticate()
          result.success("Unauthenticate success")
        }
        "getAccountDetails" ->{
          val flowAccount: FlowAccount? = getAccountDetails(call.argument<String>("address")!!)
          if(flowAccount == null){
            result.error("GetAccountDetailFailed","Get account detail error",null)
          }else{
            result.success(
              mapOf(
                "address" to flowAccount.address.toString(),
                "balance" to flowAccount.balance.toString(),
              )
            )
          }
        }
        "query" ->{
          val queryResult = query(call.argument<String>("script")!!,call.argument<List<String>>("arguments"))
          if(queryResult == null){
            result.error("QueryFailed","FCL query error",null)
          }else{
            result.success(queryResult)
          }
        }
        "mutate" ->{
          val mutationResult = mutate(call.argument<String>("script")!!,call.argument<List<String>>("arguments"),call.argument<Int>("limit"))
          if(mutationResult == null){
            result.error("MutateFailed","FCL mutate error",null)
          }else{
            result.success(mutationResult)
          }
        }
        else -> result.notImplemented()
      }
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  private fun initFCL(bloctoAppId: String,useTestNet: Boolean) {
    val walletProviderList = listOf(Blocto.getInstance(bloctoAppId))
    val env = if(useTestNet){
      Network.TESTNET
    }else{
      Network.MAINNET
    }

    Fcl.init(
      env = env,
      appDetail = AppDetail(),
      supportedWallets = walletProviderList
    )

    Log.d("fcl_flutter","Initial FCL success")
    Fcl.config.put(Config.Option.SelectedWalletProvider(Fcl.config.supportedWallets.first()))
  }

  private suspend fun simpleLogin(): String {
    val address: String = try {
      when (val result = Fcl.login()) {
        is com.portto.fcl.model.Result.Failure -> "error"
        is com.portto.fcl.model.Result.Success -> result.value
      }
    }catch (e: Exception){
      Log.d("fcl_flutter",e.toString())
      "error"
    }


    return address
  }

  private suspend fun accountProofLogin(appIdentifier: String): String{
    val newBytes = Random.nextBytes(32)
    val accountProof = AccountProofResolvedData(
      appIdentifier = appIdentifier, // human-readable string i.e. the name of your app
      nonce = newBytes.bytesToHex() // minimum 32-byte random nonce as a hex string
    )
    val address = try{
      when (val result = Fcl.authenticate(accountProof)) {
        is com.portto.fcl.model.Result.Failure -> "error"
        is com.portto.fcl.model.Result.Success -> result.value
      }
    }catch (e: Exception){
      print(e.toString())
      "error"
    }

    return address
  }

  private suspend fun verifyAccountProof(appIdentifier: String): Boolean?{
    val isValid = try{
      // accountProofData is mandatory if you wish to verify account proof
      val userAccountProofData = Fcl.currentUser?.accountProofData!!
      when (val result = Fcl.verifyAccountProof(appIdentifier, userAccountProofData)) {
        is com.portto.fcl.model.Result.Failure -> null
        is com.portto.fcl.model.Result.Success -> result.value
      }
    }catch (e: Exception){
      print(e.toString())
      null
    }

    return isValid
  }

  private suspend fun getAccountDetails(address: String): FlowAccount?{
    return try {
      AppUtils.getAccount(address)
    }catch (e: Exception){
      print(e.toString())
      null
    }
  }

  private suspend fun query(script: String, arguments: List<String>?): String?{
    val argumentsList = if (arguments == null){
      null
    }else{
      val tempList = mutableListOf<Field<*>>()
      for(item in arguments){
        tempList.add(FlowArgument(item.toByteArray()).jsonCadence)
      }
      tempList.toList()
    }
    return when (val result = Fcl.query(cadence = script,arguments = argumentsList)) {
      is com.portto.fcl.model.Result.Success -> {
        result.value.toString()
      }
      is com.portto.fcl.model.Result.Failure -> {
        print("Query failed")
        null
      }
    }
  }

  private suspend fun mutate(script: String, arguments: List<String>?, limit: Int?): String?{
    if(Fcl.currentUser == null){
      print("Please login first!!")
      return null
    }

    val argumentsList = if (arguments == null){
      null
    }else{
      val tempList = mutableListOf<FlowArgument>()
      for(item in arguments){
        tempList.add(FlowArgument(item.toByteArray()))
      }
      tempList.toList()
    }

    val gasLimit = limit?.toULong() ?: 1000u

    return when (val result = Fcl.mutate(
      cadence = script,
      arguments = argumentsList,
      limit = gasLimit,
      authorizers = listOf(FlowAddress(Fcl.currentUser!!.address)))
    ) {
      is com.portto.fcl.model.Result.Success -> {
        result.value
      }
      is com.portto.fcl.model.Result.Failure -> {
        print("Mutation failed")
        null
      }
    }
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivity() {
    activity = null
  }

}
