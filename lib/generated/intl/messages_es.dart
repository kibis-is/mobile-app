// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a es locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'es';

  static String m0(activeAccountId) =>
      "Nombre de cuenta no encontrado para activeAccountId: ${activeAccountId}";

  static String m1(accountId) =>
      "Nombre de cuenta no encontrado para accountId: ${accountId}";

  static String m2(publicKey) => "Todas las sesiones para ${publicKey}";

  static String m3(error) =>
      "Error al obtener los detalles del activo: ${error}";

  static String m4(contractId) =>
      "Activo no encontrado para el contrato ${contractId}.";

  static String m5(error) => "Error al optar por el activo: ${error}";

  static String m6(error) => "Error al llamar al contrato: ${error}";

  static String m7(error) => "Error al optar por el contrato: ${error}";

  static String m8(contactName) =>
      "¿Estás seguro de que deseas eliminar ${contactName}?";

  static String m9(index) => "Introduce la palabra ${index}";

  static String m10(error) => "Error: ${error}";

  static String m11(error) => "Error al borrar el almacenamiento: ${error}";

  static String m12(error) =>
      "Error al completar la configuración de la cuenta: ${error}";

  static String m13(error) => "Error al crear la cuenta: ${error}";

  static String m14(error) => "Error al crear el nombre de la cuenta: ${error}";

  static String m15(error) =>
      "Error al crear transacciones de transferencia sin firmar: ${error}";

  static String m16(error) =>
      "Error al crear la cuenta de observación: ${error}";

  static String m17(error) => "Error al decodificar la clave privada: ${error}";

  static String m18(error) => "Error al eliminar la cuenta: ${error}";

  static String m19(error) => "Error al destruir el activo: ${error}";

  static String m20(sessionName) =>
      "No se pudo desconectar ${sessionName}. Por favor, inténtalo de nuevo.";

  static String m21(error) =>
      "Error al desconectar sesiones WalletConnect: ${error}";

  static String m22(error) => "Error al editar el activo: ${error}";

  static String m23(contractId) =>
      "Error al obtener el saldo ARC-0200 para el contrato ${contractId}.";

  static String m24(error) => "Error al obtener activos: ${error}";

  static String m25(error) => "Error al obtener transacciones: ${error}";

  static String m26(error) =>
      "Error al finalizar la creación de la cuenta: ${error}";

  static String m27(error) =>
      "Error al obtener el saldo de la cuenta: ${error}";

  static String m28(error) => "Error al inicializar la cuenta: ${error}";

  static String m29(statusCode) =>
      "Error al cargar NFTs con el código de estado: ${statusCode}";

  static String m30(error) => "Error al optar por el ASA: ${error}";

  static String m31(error) =>
      "Error al analizar el URI de WalletConnect: ${error}";

  static String m32(error) =>
      "Error al leer los datos de las cuentas: ${error}";

  static String m33(error) => "Error al restaurar la cuenta: ${error}";

  static String m34(error) => "Error al revocar el activo: ${error}";

  static String m35(error) => "Error al guardar el contacto: ${error}";

  static String m36(error) => "Error al seleccionar la cuenta: ${error}";

  static String m37(error) => "Error al enviar el pago: ${error}";

  static String m38(error) => "Error al establecer el PIN: ${error}";

  static String m39(action, error) => "Error al ${action} el activo: ${error}";

  static String m40(error) => "Error al transferir el activo: ${error}";

  static String m41(error) =>
      "Error al obtener los activos de la cuenta: ${error}";

  static String m42(counter) => "Cuenta Importada ${counter}";

  static String m43(expected, found) =>
      "La cadena de bytes debe tener ${expected} bytes para una dirección válida, se encontró longitud \"${found}\".";

  static String m44(value) =>
      "El valor proporcionado \"${value}\" no es una dirección válida.";

  static String m45(key) =>
      "La clave no es ni Base64 válida ni Hex válida: ${key}";

  static String m46(balance, minimumBalance) =>
      "La cantidad máxima de VOI se calcula como: el saldo (${balance}), menos el saldo mínimo necesario para mantener la cuenta abierta (${minimumBalance}), menos la tarifa mínima de transacción (0.001)";

  static String m47(balance) =>
      "El saldo mínimo es ${balance} VOI. Basado en la configuración de la cuenta, este es el saldo mínimo necesario para mantener la cuenta abierta.";

  static String m48(networkName) => "Red cambiada a ${networkName}";

  static String m49(networkName) => "Fallo al cambiar a ${networkName}";

  static String m50(networkName) => "Cambiado a ${networkName}";

  static String m51(networkName) => "Red cambiada a ${networkName}";

  static String m52(partNumber) => "Parte ${partNumber}";

  static String m53(accountId) =>
      "Clave privada no encontrada para el ID de cuenta: ${accountId}";

  static String m54(error) => "Error al reiniciar la aplicación: ${error}";

  static String m55(sessionName) => "${sessionName} desconectada con éxito.";

  static String m56(contractId) =>
      "No se encontraron detalles del token para el contrato ${contractId}.";

  static String m57(error) => "Error en la transacción: ${error}";

  static String m58(maxSize) =>
      "El tamaño del grupo de transacciones excede el tamaño máximo de \"${maxSize}\"";

  static String m59(assetType) => "Tipo de activo no compatible: ${assetType}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "about": MessageLookupByLibrary.simpleMessage("Acerca de"),
        "account": MessageLookupByLibrary.simpleMessage("Cuenta"),
        "accountAlreadyAdded":
            MessageLookupByLibrary.simpleMessage("Cuenta ya añadida."),
        "accountCannotBeExported": MessageLookupByLibrary.simpleMessage(
            "Esta cuenta no se puede exportar, ya que no tiene una clave privada."),
        "accountIdOrAddressNotAvailable": MessageLookupByLibrary.simpleMessage(
            "ID de cuenta o dirección pública no disponible"),
        "accountMissingInTemporaryData": MessageLookupByLibrary.simpleMessage(
            "Falta la cuenta en los datos temporales."),
        "accountName":
            MessageLookupByLibrary.simpleMessage("Nombre de la Cuenta"),
        "accountNameIsTooLong": MessageLookupByLibrary.simpleMessage(
            "El nombre de la cuenta es demasiado largo."),
        "accountNameNotFound": m0,
        "accountNameNotFoundForId": m1,
        "accountNotFound":
            MessageLookupByLibrary.simpleMessage("Cuenta no encontrada."),
        "accountNotFundedPleaseFundToSeeDetails":
            MessageLookupByLibrary.simpleMessage(
                "Esta cuenta no ha sido financiada aún. Por favor, financia la cuenta para ver detalles."),
        "activeAssetNullError":
            MessageLookupByLibrary.simpleMessage("El activo activo es nulo"),
        "activityTab": MessageLookupByLibrary.simpleMessage("Actividad"),
        "addAccountTitle":
            MessageLookupByLibrary.simpleMessage("Añadir Cuenta"),
        "addAsset": MessageLookupByLibrary.simpleMessage("Añadir Activo"),
        "addAssetTitle": MessageLookupByLibrary.simpleMessage("Añadir Activo"),
        "addWatch": MessageLookupByLibrary.simpleMessage(
            "Añadir Cuenta de Observación"),
        "addWatchSubtitle": MessageLookupByLibrary.simpleMessage(
            "Añade una cuenta de observación para monitorear mediante dirección pública."),
        "addressType": MessageLookupByLibrary.simpleMessage("dirección"),
        "advanced": MessageLookupByLibrary.simpleMessage("Avanzado"),
        "algorandServiceError": MessageLookupByLibrary.simpleMessage(
            "Ocurrió un error con el servicio de Algorand"),
        "algorandStandardAsset":
            MessageLookupByLibrary.simpleMessage("Activo Estándar de Algorand"),
        "allAccounts":
            MessageLookupByLibrary.simpleMessage("Todas las Cuentas"),
        "allSessions":
            MessageLookupByLibrary.simpleMessage("Todas las sesiones"),
        "allSessionsFor": m2,
        "allowTestNetworks":
            MessageLookupByLibrary.simpleMessage("Permitir Redes de Prueba"),
        "almostThere": MessageLookupByLibrary.simpleMessage("Casi llegamos"),
        "alreadyAdded": MessageLookupByLibrary.simpleMessage("Ya\nagregado"),
        "amount": MessageLookupByLibrary.simpleMessage("Monto"),
        "appearance": MessageLookupByLibrary.simpleMessage("Apariencia"),
        "applicationId":
            MessageLookupByLibrary.simpleMessage("ID de Aplicación"),
        "arc0200AssetTransferSuccessful": MessageLookupByLibrary.simpleMessage(
            "Transferencia de Activo ARC-0200 exitosa."),
        "arc200AssetFetchFailed": MessageLookupByLibrary.simpleMessage(
            "Error al obtener detalles del activo ARC-0200"),
        "asset": MessageLookupByLibrary.simpleMessage("Activo"),
        "assetDestructionConfirmationFailed":
            MessageLookupByLibrary.simpleMessage(
                "Error en la confirmación de destrucción del activo."),
        "assetDetailsFetchFailed": m3,
        "assetEditConfirmationFailed": MessageLookupByLibrary.simpleMessage(
            "Error en la confirmación de edición del activo."),
        "assetIdInvalidFormat": MessageLookupByLibrary.simpleMessage(
            "Formato de ID de activo inválido. El ID de activo debe ser un número entero válido."),
        "assetIsFrozen":
            MessageLookupByLibrary.simpleMessage("El activo está congelado."),
        "assetNameOrUnitMissing": MessageLookupByLibrary.simpleMessage(
            "Falta el nombre del activo o el nombre de la unidad."),
        "assetNotFoundForContract": m4,
        "assetOptInConfirmationFailed": MessageLookupByLibrary.simpleMessage(
            "Error en la confirmación de adhesión al activo."),
        "assetOptInFailed": m5,
        "assetOptInSuccess":
            MessageLookupByLibrary.simpleMessage("Activo añadido con éxito"),
        "assetTransfer":
            MessageLookupByLibrary.simpleMessage("Transferencia de Activos"),
        "assetTransferConfirmationFailed": MessageLookupByLibrary.simpleMessage(
            "Error en la confirmación de transferencia del activo."),
        "assetsTab": MessageLookupByLibrary.simpleMessage("Activos"),
        "authenticating": MessageLookupByLibrary.simpleMessage("Autenticando"),
        "back": MessageLookupByLibrary.simpleMessage("Atrás"),
        "backupConfirmationPrompt": MessageLookupByLibrary.simpleMessage(
            "Por favor, confirma que has guardado una copia de seguridad de tu frase semilla en un lugar seguro."),
        "backupConfirmationRequired": MessageLookupByLibrary.simpleMessage(
            "Debes confirmar que has hecho una copia de seguridad de tu frase semilla."),
        "build": MessageLookupByLibrary.simpleMessage("Compilación:"),
        "buildNumber":
            MessageLookupByLibrary.simpleMessage("Número de Compilación:"),
        "calculating": MessageLookupByLibrary.simpleMessage("Calculando..."),
        "cancel": MessageLookupByLibrary.simpleMessage("Cancelar"),
        "cancelButton": MessageLookupByLibrary.simpleMessage("Cancelar"),
        "changePin": MessageLookupByLibrary.simpleMessage("Cambiar PIN"),
        "checksumMismatch": MessageLookupByLibrary.simpleMessage(
            "El checksum no coincide. Los códigos QR escaneados no son del mismo conjunto."),
        "clearFilter": MessageLookupByLibrary.simpleMessage("Borrar Filtro"),
        "close": MessageLookupByLibrary.simpleMessage("Cerrar"),
        "confirm": MessageLookupByLibrary.simpleMessage("Confirmar"),
        "confirmDeleteAccount": MessageLookupByLibrary.simpleMessage(
            "¿Estás seguro de que deseas eliminar esta cuenta?"),
        "confirmPin": MessageLookupByLibrary.simpleMessage("Confirmar PIN"),
        "confirmReset":
            MessageLookupByLibrary.simpleMessage("Confirmar Restablecimiento"),
        "connectTitle": MessageLookupByLibrary.simpleMessage("Conectar"),
        "connectToTitle": MessageLookupByLibrary.simpleMessage("Conectar a:"),
        "contactNameOptional": MessageLookupByLibrary.simpleMessage(
            "Nombre del Contacto (Opcional)"),
        "contactNameUpdatedSuccessfully": MessageLookupByLibrary.simpleMessage(
            "Nombre del contacto actualizado con éxito."),
        "contactNotFound":
            MessageLookupByLibrary.simpleMessage("Contacto no encontrado."),
        "contactSavedSuccessfully": MessageLookupByLibrary.simpleMessage(
            "Contacto guardado con éxito."),
        "contactsTab": MessageLookupByLibrary.simpleMessage("Contactos"),
        "contractCallFailed": m6,
        "contractOptInFailed": m7,
        "copiedToClipboard":
            MessageLookupByLibrary.simpleMessage("Copiado al portapapeles"),
        "copyAddress": MessageLookupByLibrary.simpleMessage("Copiar Dirección"),
        "copySeed":
            MessageLookupByLibrary.simpleMessage("Copiar Frase Semilla"),
        "copySeedPhrase":
            MessageLookupByLibrary.simpleMessage("Copiar frase semilla"),
        "copyUri": MessageLookupByLibrary.simpleMessage("Copiar URI"),
        "create": MessageLookupByLibrary.simpleMessage("Crear"),
        "createNewAccount":
            MessageLookupByLibrary.simpleMessage("Crear Nueva Cuenta"),
        "createNewAccountSubtitle": MessageLookupByLibrary.simpleMessage(
            "Se te pedirá que guardes una frase semilla."),
        "createPin": MessageLookupByLibrary.simpleMessage("Crear PIN"),
        "creatingAccount":
            MessageLookupByLibrary.simpleMessage("Creando Cuenta"),
        "dangerZone": MessageLookupByLibrary.simpleMessage("Zona de Peligro"),
        "dangerZoneDescription": MessageLookupByLibrary.simpleMessage(
            "Esto eliminará todas las cuentas, configuraciones e información de seguridad."),
        "darkMode": MessageLookupByLibrary.simpleMessage("Modo Oscuro"),
        "date": MessageLookupByLibrary.simpleMessage("Fecha"),
        "decimals": MessageLookupByLibrary.simpleMessage("Decimales"),
        "defaultConfirmationContent": MessageLookupByLibrary.simpleMessage(
            "¿Quieres proceder con esta acción?"),
        "defaultConfirmationTitle":
            MessageLookupByLibrary.simpleMessage("¿Estás seguro?"),
        "defaultErrorMessage": MessageLookupByLibrary.simpleMessage(
            "Hubo un error. No se proporcionaron más detalles."),
        "delete": MessageLookupByLibrary.simpleMessage("Eliminar"),
        "deleteContactMessage": m8,
        "deleteContactTitle":
            MessageLookupByLibrary.simpleMessage("Eliminar Contacto"),
        "disconnect": MessageLookupByLibrary.simpleMessage("Desconectar"),
        "disconnectAll":
            MessageLookupByLibrary.simpleMessage("Desconectar Todo"),
        "disconnectAllSessions": MessageLookupByLibrary.simpleMessage(
            "¿Desconectar Todas las Sesiones?"),
        "disconnectAllSessionsForAccountPrompt":
            MessageLookupByLibrary.simpleMessage(
                "¿Desconectar todas las sesiones para esta cuenta?"),
        "disconnectAllSessionsPrompt": MessageLookupByLibrary.simpleMessage(
            "¿Desconectar todas las sesiones?"),
        "downloadQrImage":
            MessageLookupByLibrary.simpleMessage("Descargar Imagen QR"),
        "editAccount": MessageLookupByLibrary.simpleMessage("Editar"),
        "editAccountDescription": MessageLookupByLibrary.simpleMessage(
            "Puedes cambiar el nombre de tu cuenta a continuación."),
        "editAccountNamePrompt": MessageLookupByLibrary.simpleMessage(
            "Edita el nombre de tu cuenta"),
        "enablePasswordLock": MessageLookupByLibrary.simpleMessage(
            "Activar Bloqueo con Contraseña"),
        "enterSeedPhrasePrompt": MessageLookupByLibrary.simpleMessage(
            "Introduce tu frase semilla para importar tu cuenta."),
        "enterWord": m9,
        "error": MessageLookupByLibrary.simpleMessage("Error"),
        "errorLoadingAccounts":
            MessageLookupByLibrary.simpleMessage("Error al cargar las cuentas"),
        "errorLoadingAssets":
            MessageLookupByLibrary.simpleMessage("Error al cargar los activos"),
        "errorLoadingTransactions": MessageLookupByLibrary.simpleMessage(
            "Error al cargar las transacciones"),
        "errorMessage": m10,
        "errorProcessingPublicKey": MessageLookupByLibrary.simpleMessage(
            "Error al procesar la clave pública"),
        "errorReadingPinHash": MessageLookupByLibrary.simpleMessage(
            "Error al leer el hash del PIN."),
        "errorTitle": MessageLookupByLibrary.simpleMessage("Error"),
        "expectedPrivateKeyButPublic": MessageLookupByLibrary.simpleMessage(
            "Se esperaba un código QR de clave privada, pero se encontró una clave pública."),
        "expectedPrivateKeyButWalletConnect": MessageLookupByLibrary.simpleMessage(
            "Se esperaba un código QR de clave privada, pero se encontró un URI de WalletConnect."),
        "expectedPrivateKeyQr": MessageLookupByLibrary.simpleMessage(
            "Se esperaba un código QR de clave privada, pero se encontró una clave pública."),
        "expectedPublicKey": MessageLookupByLibrary.simpleMessage(
            "Se esperaba un código QR de clave pública, pero se encontró otra cosa."),
        "expectedPublicKeyQr": MessageLookupByLibrary.simpleMessage(
            "Se esperaba un código QR de clave pública, pero se encontró otra cosa."),
        "expectedWalletConnectSessionQr": MessageLookupByLibrary.simpleMessage(
            "Se esperaba un código QR de sesión de WalletConnect, pero se encontró otra cosa."),
        "expectedWalletConnectUri": MessageLookupByLibrary.simpleMessage(
            "Se esperaba un código QR de clave privada, pero se encontró un URI de WalletConnect."),
        "expires": MessageLookupByLibrary.simpleMessage("Expira:"),
        "exportAccounts":
            MessageLookupByLibrary.simpleMessage("Exportar Cuentas"),
        "failedFinalizeAccountImport": MessageLookupByLibrary.simpleMessage(
            "Error al finalizar la importación de la cuenta."),
        "failedParseWalletConnectUri": MessageLookupByLibrary.simpleMessage(
            "Error al analizar el URI de WalletConnect"),
        "failedToApproveSession":
            MessageLookupByLibrary.simpleMessage("Error al aprobar la sesión."),
        "failedToClearStorage": m11,
        "failedToCompleteAccountSetup": m12,
        "failedToCreateAccount": m13,
        "failedToCreateAccountName": m14,
        "failedToCreateUnsignedTransactions": m15,
        "failedToCreateWatchAccount": m16,
        "failedToDecodePrivateKey": m17,
        "failedToDeleteAccount": m18,
        "failedToDestroyAsset": m19,
        "failedToDisconnect": m20,
        "failedToDisconnectSession": MessageLookupByLibrary.simpleMessage(
            "Error al desconectar la sesión."),
        "failedToDisconnectWalletConnectSessions": m21,
        "failedToEditAsset": m22,
        "failedToFetchArc200Balance": m23,
        "failedToFetchAssets": m24,
        "failedToFetchTransactions": m25,
        "failedToFinalizeAccountCreation": m26,
        "failedToFollowArc200Asset": MessageLookupByLibrary.simpleMessage(
            "Error al seguir el activo ARC-0200."),
        "failedToGetAccountBalance": m27,
        "failedToInitializeAccount": m28,
        "failedToLoad":
            MessageLookupByLibrary.simpleMessage("No se pudo cargar"),
        "failedToLoadArc200Balances": MessageLookupByLibrary.simpleMessage(
            "Error al cargar los saldos ARC-0200."),
        "failedToLoadArc200TokenDetails": MessageLookupByLibrary.simpleMessage(
            "Error al cargar los detalles del token ARC-0200."),
        "failedToLoadNFTs": m29,
        "failedToOptInAsset": MessageLookupByLibrary.simpleMessage(
            "Error al optar por el activo."),
        "failedToOptInError":
            MessageLookupByLibrary.simpleMessage("Error al añadir el activo"),
        "failedToOptInToASA": m30,
        "failedToParseWalletConnectUri": m31,
        "failedToReadAccountsData": m32,
        "failedToRemoveSessions": MessageLookupByLibrary.simpleMessage(
            "Error al eliminar las sesiones."),
        "failedToRestoreAccount": m33,
        "failedToRetrieveSessions": MessageLookupByLibrary.simpleMessage(
            "Error al recuperar las sesiones."),
        "failedToRevokeAsset": m34,
        "failedToSaveContact": m35,
        "failedToSaveSessions": MessageLookupByLibrary.simpleMessage(
            "Error al guardar las sesiones."),
        "failedToSearchArc200Assets": MessageLookupByLibrary.simpleMessage(
            "Error al buscar activos ARC-0200."),
        "failedToSelectAccount": m36,
        "failedToSendPayment": m37,
        "failedToSetPin": m38,
        "failedToToggleFreeze": m39,
        "failedToTransferAsset": m40,
        "fee": MessageLookupByLibrary.simpleMessage("Tarifa"),
        "filter": MessageLookupByLibrary.simpleMessage("Filtrar"),
        "fromField": MessageLookupByLibrary.simpleMessage("De"),
        "fundAccountError": MessageLookupByLibrary.simpleMessage(
            "Por favor, financia tu cuenta para continuar."),
        "general": MessageLookupByLibrary.simpleMessage("General"),
        "generateSeedPhrase":
            MessageLookupByLibrary.simpleMessage("Generar frase semilla"),
        "genericError": MessageLookupByLibrary.simpleMessage("Error"),
        "genericErrorMessage": MessageLookupByLibrary.simpleMessage(
            "Lo sentimos, ocurrió un error."),
        "getAccountAssetsFailed": m41,
        "hangInThere":
            MessageLookupByLibrary.simpleMessage("Aguanta un poco más"),
        "hereIsMyQRCode":
            MessageLookupByLibrary.simpleMessage("¡Aquí está mi código QR!"),
        "import": MessageLookupByLibrary.simpleMessage("Importar"),
        "importAccountTitle":
            MessageLookupByLibrary.simpleMessage("Importar Cuenta"),
        "importPrivateKey":
            MessageLookupByLibrary.simpleMessage("Importar Clave Privada"),
        "importPublicAddress":
            MessageLookupByLibrary.simpleMessage("Importar Dirección Pública"),
        "importSeed":
            MessageLookupByLibrary.simpleMessage("Importar Frase Semilla"),
        "importViaPrivateKey":
            MessageLookupByLibrary.simpleMessage("Importar con Clave Privada"),
        "importViaPrivateKeySubtitle": MessageLookupByLibrary.simpleMessage(
            "Importa cuentas con una clave privada."),
        "importViaQrCode":
            MessageLookupByLibrary.simpleMessage("Importar con Código QR"),
        "importViaQrCodeSubtitle": MessageLookupByLibrary.simpleMessage(
            "Escanea un código QR para importar una cuenta existente."),
        "importViaSeed":
            MessageLookupByLibrary.simpleMessage("Importar con Frase Semilla"),
        "importViaSeedSubtitle": MessageLookupByLibrary.simpleMessage(
            "Importa una cuenta existente con una frase semilla."),
        "importedAccount":
            MessageLookupByLibrary.simpleMessage("Cuenta Importada"),
        "importedAccountWithCounter": m42,
        "incompleteTemporaryAccountData": MessageLookupByLibrary.simpleMessage(
            "Datos temporales de cuenta incompletos para cuenta regular."),
        "incorrectPin": MessageLookupByLibrary.simpleMessage("PIN incorrecto"),
        "incorrectPinError": MessageLookupByLibrary.simpleMessage(
            "PIN incorrecto. Inténtalo de nuevo."),
        "info": MessageLookupByLibrary.simpleMessage("Información"),
        "infoHeader": MessageLookupByLibrary.simpleMessage("Información"),
        "initializationError": MessageLookupByLibrary.simpleMessage(
            "Error de inicialización, por favor reinicia la aplicación."),
        "initializing": MessageLookupByLibrary.simpleMessage("Iniciando"),
        "insufficientBalance":
            MessageLookupByLibrary.simpleMessage("Saldo insuficiente."),
        "insufficientFunds":
            MessageLookupByLibrary.simpleMessage("Fondos insuficientes"),
        "insufficientFundsError":
            MessageLookupByLibrary.simpleMessage("Fondos insuficientes."),
        "invalidAddressByteLength": m43,
        "invalidAddressSupplied": m44,
        "invalidAlgorandAddress": MessageLookupByLibrary.simpleMessage(
            "Dirección de Algorand inválida."),
        "invalidBase32String":
            MessageLookupByLibrary.simpleMessage("Cadena Base32 inválida."),
        "invalidBase64String":
            MessageLookupByLibrary.simpleMessage("Cadena Base64 inválida."),
        "invalidEncodedKeyLength": MessageLookupByLibrary.simpleMessage(
            "La clave codificada debe tener 44 caracteres."),
        "invalidHexStringLength": MessageLookupByLibrary.simpleMessage(
            "Longitud de cadena hexadecimal inválida."),
        "invalidIconType": MessageLookupByLibrary.simpleMessage(
            "El icono debe ser IconData o una ruta de archivo SVG."),
        "invalidPageFormat": MessageLookupByLibrary.simpleMessage(
            "Formato de página inválido en URI paginado"),
        "invalidPageFormatInUri": MessageLookupByLibrary.simpleMessage(
            "Formato de página inválido en URI paginado"),
        "invalidPinTryAgain": MessageLookupByLibrary.simpleMessage(
            "PIN inválido. Intenta de nuevo."),
        "invalidPrivateKey":
            MessageLookupByLibrary.simpleMessage("Clave privada inválida"),
        "invalidPrivateKeyLength": MessageLookupByLibrary.simpleMessage(
            "Longitud de clave privada inválida."),
        "invalidPublicKeyFormat": MessageLookupByLibrary.simpleMessage(
            "Formato de Clave Pública Inválido"),
        "invalidQrCodeData": MessageLookupByLibrary.simpleMessage(
            "Datos del código QR inválidos"),
        "invalidScanResult": MessageLookupByLibrary.simpleMessage(
            "Resultado de escaneo inválido"),
        "invalidUriFormat":
            MessageLookupByLibrary.simpleMessage("Formato de URI inválido"),
        "invalidWalletConnectUri": MessageLookupByLibrary.simpleMessage(
            "Formato de URI de WalletConnect inválido."),
        "justABitMore":
            MessageLookupByLibrary.simpleMessage("Solo un poco más"),
        "keyNeitherBase64NorHex": m45,
        "language": MessageLookupByLibrary.simpleMessage("Idioma"),
        "loading": MessageLookupByLibrary.simpleMessage("Cargando..."),
        "loadingAccount":
            MessageLookupByLibrary.simpleMessage("Cargando Cuenta"),
        "max": MessageLookupByLibrary.simpleMessage("Máximo"),
        "maxVoiAmountCalculation": m46,
        "minimumBalanceInfo": m47,
        "missingPrivateKeyInLegacyUri": MessageLookupByLibrary.simpleMessage(
            "Falta la clave privada en el URI heredado"),
        "missingPrivateKeyLegacy": MessageLookupByLibrary.simpleMessage(
            "Falta la clave privada en el URI heredado"),
        "myAccountsTab": MessageLookupByLibrary.simpleMessage("Mis Cuentas"),
        "nameAccount": MessageLookupByLibrary.simpleMessage("Nombrar Cuenta"),
        "nameAccountDescription": MessageLookupByLibrary.simpleMessage(
            "Dale un apodo a tu cuenta. No te preocupes, puedes cambiarlo más tarde."),
        "nameAccountPrompt":
            MessageLookupByLibrary.simpleMessage("Nombra tu cuenta"),
        "nearlyDone": MessageLookupByLibrary.simpleMessage("Casi terminado"),
        "networkChangedTo": m48,
        "networkNotConfiguredForArc200": MessageLookupByLibrary.simpleMessage(
            "La red no está configurada para operaciones ARC-0200."),
        "networkSwitchFailure": m49,
        "networkSwitchSuccess": m50,
        "networkSwitched": m51,
        "next": MessageLookupByLibrary.simpleMessage("Siguiente"),
        "nextQrCode": MessageLookupByLibrary.simpleMessage("Siguiente QR:"),
        "nftViewerTitle": MessageLookupByLibrary.simpleMessage("Visor de NFTs"),
        "nftsTab": MessageLookupByLibrary.simpleMessage("NFTs"),
        "no": MessageLookupByLibrary.simpleMessage("No"),
        "noAccount": MessageLookupByLibrary.simpleMessage("Sin cuenta"),
        "noAccountName":
            MessageLookupByLibrary.simpleMessage("Sin Nombre de Cuenta"),
        "noAccountsAvailableToConnect": MessageLookupByLibrary.simpleMessage(
            "No hay cuentas disponibles para conectar."),
        "noAccountsForExport": MessageLookupByLibrary.simpleMessage(
            "No hay cuentas disponibles para exportar."),
        "noAccountsFound":
            MessageLookupByLibrary.simpleMessage("No se encontraron cuentas"),
        "noActiveAccount":
            MessageLookupByLibrary.simpleMessage("No hay cuenta activa."),
        "noActiveAccountFound": MessageLookupByLibrary.simpleMessage(
            "No se encontró ninguna cuenta activa."),
        "noActiveAccountIdFound": MessageLookupByLibrary.simpleMessage(
            "No se encontró ID de cuenta activa"),
        "noActiveAccountToUpdate": MessageLookupByLibrary.simpleMessage(
            "No hay cuenta activa para actualizar."),
        "noActiveSessions":
            MessageLookupByLibrary.simpleMessage("No hay sesiones activas."),
        "noArc200TokenDetailsForNetwork": MessageLookupByLibrary.simpleMessage(
            "No hay detalles de tokens ARC-0200 disponibles para la red seleccionada."),
        "noAssetAvailableMessage": MessageLookupByLibrary.simpleMessage(
            "No hay activo disponible para mostrar."),
        "noAssets":
            MessageLookupByLibrary.simpleMessage("No se encontraron activos."),
        "noAssetsAdded": MessageLookupByLibrary.simpleMessage(
            "No has agregado ningún activo."),
        "noAssetsForFilter": MessageLookupByLibrary.simpleMessage(
            "No se encontraron activos para el filtro"),
        "noAssetsFound":
            MessageLookupByLibrary.simpleMessage("No se encontraron activos."),
        "noInternetConnection":
            MessageLookupByLibrary.simpleMessage("Sin conexión a Internet"),
        "noItemSelectedForTransaction": MessageLookupByLibrary.simpleMessage(
            "No se seleccionó ningún elemento para la transacción."),
        "noItems": MessageLookupByLibrary.simpleMessage("Sin elementos"),
        "noMoreTransactions":
            MessageLookupByLibrary.simpleMessage("No hay más transacciones."),
        "noNetwork": MessageLookupByLibrary.simpleMessage("Sin Red"),
        "noNftsAdded":
            MessageLookupByLibrary.simpleMessage("No has agregado ningún NFT."),
        "noNftsForFilter": MessageLookupByLibrary.simpleMessage(
            "No se encontraron NFTs para el filtro"),
        "noNftsFound":
            MessageLookupByLibrary.simpleMessage("No se encontraron NFTs."),
        "noPublicKey":
            MessageLookupByLibrary.simpleMessage("Sin Clave Pública"),
        "noSeedPhraseAvailable": MessageLookupByLibrary.simpleMessage(
            "No hay frase semilla disponible."),
        "noTransactionAvailable": MessageLookupByLibrary.simpleMessage(
            "No hay transacción disponible para mostrar."),
        "noTransactionsFound": MessageLookupByLibrary.simpleMessage(
            "No se encontraron transacciones."),
        "noTransactionsMade": MessageLookupByLibrary.simpleMessage(
            "No has realizado ninguna transacción."),
        "notAvailable": MessageLookupByLibrary.simpleMessage("No disponible"),
        "note": MessageLookupByLibrary.simpleMessage("Nota"),
        "noteOptional": MessageLookupByLibrary.simpleMessage("Nota (Opcional)"),
        "noteTooLarge": MessageLookupByLibrary.simpleMessage(
            "La nota es demasiado grande."),
        "ok": MessageLookupByLibrary.simpleMessage("Aceptar"),
        "optOutAssetContent": MessageLookupByLibrary.simpleMessage(
            "¿Estás seguro de que deseas optar por salir de este activo ARC-0200?"),
        "optOutAssetTitle": MessageLookupByLibrary.simpleMessage(
            "¿Optar por salir del activo?"),
        "optOutButton": MessageLookupByLibrary.simpleMessage("Optar Salida"),
        "optOutTooltip": MessageLookupByLibrary.simpleMessage("Optar Salida"),
        "optingInMessage":
            MessageLookupByLibrary.simpleMessage("Añadiendo activo..."),
        "options": MessageLookupByLibrary.simpleMessage("Opciones"),
        "paginatedUriMissingInfo": MessageLookupByLibrary.simpleMessage(
            "URI paginado carece de información de checksum o página"),
        "partNumber": m52,
        "payment": MessageLookupByLibrary.simpleMessage("Pago"),
        "pinMismatchError":
            MessageLookupByLibrary.simpleMessage("El PIN no coincide."),
        "pleaseEnterPublicAddress": MessageLookupByLibrary.simpleMessage(
            "Por favor, introduce una dirección pública."),
        "pleaseEnterText":
            MessageLookupByLibrary.simpleMessage("Por favor, introduce texto"),
        "pleaseEnterValidAlgorandAddress": MessageLookupByLibrary.simpleMessage(
            "Por favor, introduce una dirección de Algorand válida"),
        "pleaseEnterValidAmount": MessageLookupByLibrary.simpleMessage(
            "Por favor, introduce un monto válido"),
        "pleaseWait": MessageLookupByLibrary.simpleMessage("Por favor espera"),
        "privateKey": MessageLookupByLibrary.simpleMessage("Clave Privada"),
        "privateKeyMissingInUri": MessageLookupByLibrary.simpleMessage(
            "Falta la clave privada en la URI."),
        "privateKeyNotFound": MessageLookupByLibrary.simpleMessage(
            "Clave privada no encontrada para la cuenta activa."),
        "privateKeyNotFoundError":
            MessageLookupByLibrary.simpleMessage("Clave privada no encontrada"),
        "privateKeyNotFoundForAccount": m53,
        "privateKeyNotFoundInStorage": MessageLookupByLibrary.simpleMessage(
            "Clave privada no encontrada en el almacenamiento"),
        "processingQrCode":
            MessageLookupByLibrary.simpleMessage("Procesando Código QR"),
        "publicAddress":
            MessageLookupByLibrary.simpleMessage("Dirección Pública"),
        "publicAddressNotAvailable": MessageLookupByLibrary.simpleMessage(
            "Dirección pública no disponible."),
        "publicKeyIsMissing":
            MessageLookupByLibrary.simpleMessage("Falta la clave pública."),
        "publicKeyNotFoundInStorage": MessageLookupByLibrary.simpleMessage(
            "Clave pública no encontrada en el almacenamiento."),
        "pullToRefresh": MessageLookupByLibrary.simpleMessage(
            "Tira hacia abajo para actualizar"),
        "qrCodeScannerTitle":
            MessageLookupByLibrary.simpleMessage("Escáner de Código QR"),
        "receivedTransactionTitle":
            MessageLookupByLibrary.simpleMessage("Transacción Recibida"),
        "recipientAddress":
            MessageLookupByLibrary.simpleMessage("Dirección del Destinatario"),
        "refreshAccount": MessageLookupByLibrary.simpleMessage("Actualizar"),
        "refreshing": MessageLookupByLibrary.simpleMessage("Actualizando..."),
        "releaseToRefresh":
            MessageLookupByLibrary.simpleMessage("Suelta para actualizar"),
        "reset": MessageLookupByLibrary.simpleMessage("Restablecer"),
        "resetAppFailed": m54,
        "resetConfirmationMessage": MessageLookupByLibrary.simpleMessage(
            "¿Estás seguro de que deseas restablecer este dispositivo? Esto eliminará todas las cuentas, configuraciones e información de seguridad."),
        "resettingApp": MessageLookupByLibrary.simpleMessage(
            "Restableciendo la Aplicación"),
        "retry": MessageLookupByLibrary.simpleMessage("Reintentar"),
        "save": MessageLookupByLibrary.simpleMessage("Guardar"),
        "scanAddressTitle":
            MessageLookupByLibrary.simpleMessage("Escanear Dirección"),
        "scanQrCode":
            MessageLookupByLibrary.simpleMessage("Escanear Código QR"),
        "searchPrompt": MessageLookupByLibrary.simpleMessage(
            "Ingresa un assetID, nombre, activo o ID de símbolo (para ARC-200)."),
        "searchQueryLabel":
            MessageLookupByLibrary.simpleMessage("Consulta de búsqueda"),
        "searchQueryTooShort": MessageLookupByLibrary.simpleMessage(
            "La consulta de búsqueda es demasiado corta."),
        "security": MessageLookupByLibrary.simpleMessage("Seguridad"),
        "seedPhraseDescription": MessageLookupByLibrary.simpleMessage(
            "Aquí está tu frase semilla de 25 palabras. Asegúrate de guardarla en un lugar seguro."),
        "seedPhraseNotAvailable": MessageLookupByLibrary.simpleMessage(
            "Frase semilla no disponible."),
        "seedPhraseNotFoundInStorage": MessageLookupByLibrary.simpleMessage(
            "Frase semilla no encontrada en el almacenamiento."),
        "selectAccountTitle":
            MessageLookupByLibrary.simpleMessage("Seleccionar Cuenta"),
        "selectAsset":
            MessageLookupByLibrary.simpleMessage("Seleccionar Activo"),
        "selectNetworkHeader":
            MessageLookupByLibrary.simpleMessage("Seleccionar Red"),
        "selectTimeout": MessageLookupByLibrary.simpleMessage(
            "Seleccionar Tiempo de Espera"),
        "selectTransactionPrompt": MessageLookupByLibrary.simpleMessage(
            "Selecciona una transacción para ver detalles"),
        "selfTransferTitle":
            MessageLookupByLibrary.simpleMessage("Transferencia Propia"),
        "send": MessageLookupByLibrary.simpleMessage("Enviar"),
        "sendAsset": MessageLookupByLibrary.simpleMessage("Enviar Activo"),
        "sendTransactionTitle":
            MessageLookupByLibrary.simpleMessage("Enviar Transacción"),
        "sendingAsset": MessageLookupByLibrary.simpleMessage("Enviando Activo"),
        "sendingPayment": MessageLookupByLibrary.simpleMessage("Enviando Pago"),
        "sentTransactionTitle":
            MessageLookupByLibrary.simpleMessage("Transacción Enviada"),
        "sessionDisconnected": m55,
        "sessions": MessageLookupByLibrary.simpleMessage("Sesiones"),
        "settingNewPin":
            MessageLookupByLibrary.simpleMessage("Estableciendo un nuevo PIN"),
        "settingUp": MessageLookupByLibrary.simpleMessage("Configurando"),
        "settings": MessageLookupByLibrary.simpleMessage("Configuración"),
        "shareAddress":
            MessageLookupByLibrary.simpleMessage("Compartir Dirección"),
        "shareQr": MessageLookupByLibrary.simpleMessage("Compartir QR"),
        "sharedPreferencesNotInitialized": MessageLookupByLibrary.simpleMessage(
            "SharedPreferences no está inicializado."),
        "showFrozenAssets":
            MessageLookupByLibrary.simpleMessage("Mostrar Activos Congelados"),
        "somethingWentWrong":
            MessageLookupByLibrary.simpleMessage("Algo salió mal."),
        "sortAndFilter":
            MessageLookupByLibrary.simpleMessage("Ordenar y Filtrar Activos"),
        "standardAssetTransferSuccessful": MessageLookupByLibrary.simpleMessage(
            "Transferencia de Activo Estándar exitosa."),
        "successfullyConnected":
            MessageLookupByLibrary.simpleMessage("Conectado con éxito"),
        "thanksForWaiting":
            MessageLookupByLibrary.simpleMessage("Gracias por esperar"),
        "timeout": MessageLookupByLibrary.simpleMessage("Tiempo de Espera"),
        "timeout10Minutes": MessageLookupByLibrary.simpleMessage("10 minutos"),
        "timeout15Minutes": MessageLookupByLibrary.simpleMessage("15 minutos"),
        "timeout1Minute": MessageLookupByLibrary.simpleMessage("1 minuto"),
        "timeout2Minutes": MessageLookupByLibrary.simpleMessage("2 minutos"),
        "timeout5Minutes": MessageLookupByLibrary.simpleMessage("5 minutos"),
        "toField": MessageLookupByLibrary.simpleMessage("Para"),
        "toggleTestNetworksDescription": MessageLookupByLibrary.simpleMessage(
            "Activar para incluir redes de prueba en la lista de redes."),
        "tokenDetailsNotFound": m56,
        "totalSupply": MessageLookupByLibrary.simpleMessage("Suministro Total"),
        "transactionError": m57,
        "transactionFailed":
            MessageLookupByLibrary.simpleMessage("Transacción fallida"),
        "transactionFailedToConfirm": MessageLookupByLibrary.simpleMessage(
            "La transacción no se confirmó dentro de las rondas esperadas."),
        "transactionGroupSizeExceeded": m58,
        "transactionId":
            MessageLookupByLibrary.simpleMessage("ID de Transacción"),
        "transactionIdCopied":
            MessageLookupByLibrary.simpleMessage("ID de Transacción Copiado"),
        "transactionIdInvalid": MessageLookupByLibrary.simpleMessage(
            "Error en la transacción: ID de transacción inválido o marcado como \'error\'."),
        "transactionSuccessful":
            MessageLookupByLibrary.simpleMessage("Transacción exitosa"),
        "transactionType":
            MessageLookupByLibrary.simpleMessage("Tipo de Transacción"),
        "tryClearingFilter": MessageLookupByLibrary.simpleMessage(
            "Intenta borrar el filtro para ver todos los activos."),
        "type": MessageLookupByLibrary.simpleMessage("Tipo"),
        "unknown": MessageLookupByLibrary.simpleMessage("Desconocido"),
        "unknownImportAccountUriFormat": MessageLookupByLibrary.simpleMessage(
            "Formato de URI de importación de cuenta desconocido"),
        "unknownImportUriFormat": MessageLookupByLibrary.simpleMessage(
            "Formato de URI de importación de cuenta desconocido"),
        "unknownQrCodeType": MessageLookupByLibrary.simpleMessage(
            "Tipo de Código QR desconocido"),
        "unknownWalletConnectVersion": MessageLookupByLibrary.simpleMessage(
            "Versión desconocida de WalletConnect. No se puede emparejar."),
        "unlock": MessageLookupByLibrary.simpleMessage("Desbloquear"),
        "unnamedAccount":
            MessageLookupByLibrary.simpleMessage("Cuenta Sin Nombre"),
        "unnamedAsset":
            MessageLookupByLibrary.simpleMessage("Activo Sin Nombre"),
        "unsupportedAccountType": MessageLookupByLibrary.simpleMessage(
            "Tipo de cuenta no soportado."),
        "unsupportedAssetType": m59,
        "unsupportedEncodingInUri": MessageLookupByLibrary.simpleMessage(
            "Codificación no soportada en la URI."),
        "unsupportedEncodingOrInvalidFormat":
            MessageLookupByLibrary.simpleMessage(
                "Codificación no soportada o formato de cadena inválido."),
        "updatingAccount":
            MessageLookupByLibrary.simpleMessage("Actualizando Cuenta"),
        "verifyPin": MessageLookupByLibrary.simpleMessage("Verificar PIN"),
        "verifying": MessageLookupByLibrary.simpleMessage("Verificando"),
        "version": MessageLookupByLibrary.simpleMessage("Versión:"),
        "viewAssetTitle": MessageLookupByLibrary.simpleMessage("Ver Activo"),
        "viewTransactionTitle":
            MessageLookupByLibrary.simpleMessage("Ver Transacción"),
        "walletConnectV1NotSupported": MessageLookupByLibrary.simpleMessage(
            "Los URIs de WalletConnect V1 no son compatibles."),
        "welcomeMessage": MessageLookupByLibrary.simpleMessage(
            "Bienvenido. Primero, vamos a crear un nuevo código PIN para asegurar este dispositivo."),
        "welcomeTitle": MessageLookupByLibrary.simpleMessage("Bienvenido"),
        "yes": MessageLookupByLibrary.simpleMessage("Sí"),
        "youreDoingGreat":
            MessageLookupByLibrary.simpleMessage("Lo estás haciendo genial")
      };
}
