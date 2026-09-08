import Foundation
import RMStore

// MARK: 商店数据

/// 商店数据
class Subscribe_Base_one: NSObject {
    
    /// 单例
    static let shared_Base_one = Subscribe_Base_one()
    
    // 是否VIP
    var isVIP_Base_one: Bool = false
    
    // 是否购买一次性商品
    var isPur_Base_one: Bool = false
    
    // 礼物商品列表
    var goodsList_Base_one: [StoreModel_Base_one] = [
        StoreModel_Base_one(
            id_Base_one: 1,
            goodsId_Base_one: "praise.gift.4_9",
            goodsName_Base_one: "x1",
            goodsPrice_Base_one: "$4.99",
            goodIsTop_Base_one: true
        ),
        StoreModel_Base_one(
            id_Base_one: 2,
            goodsId_Base_one: "praise.gift.x1.4_9",
            goodsName_Base_one: "x1",
            goodsPrice_Base_one: "$4.99",
        ),
        StoreModel_Base_one(
            id_Base_one: 3,
            goodsId_Base_one: "praise.gift.x5.14_9",
            goodsName_Base_one: "x5",
            goodsPrice_Base_one: "$14.99",
        ),
        StoreModel_Base_one(
            id_Base_one: 4,
            goodsId_Base_one: "praise.gift.x10.19_9",
            goodsName_Base_one: "x10",
            goodsPrice_Base_one: "$19.99",
        ),
        StoreModel_Base_one(
            id_Base_one: 5,
            goodsId_Base_one: "praise.gift.x30.49_9",
            goodsName_Base_one: "x30",
            goodsPrice_Base_one: "$49.99",
        ),
        StoreModel_Base_one(
            id_Base_one: 6,
            goodsId_Base_one: "praise.gift.x1.6_9",
            goodsName_Base_one: "x1",
            goodsPrice_Base_one: "$6.99",
        ),
        StoreModel_Base_one(
            id_Base_one: 7,
            goodsId_Base_one: "praise.gift.x5.19_9",
            goodsName_Base_one: "x5",
            goodsPrice_Base_one: "$19.99",
        ),
        StoreModel_Base_one(
            id_Base_one: 8,
            goodsId_Base_one: "praise.gift.x10.29_9",
            goodsName_Base_one: "x10",
            goodsPrice_Base_one: "$29.99",
        ),
        StoreModel_Base_one(
            id_Base_one: 9,
            goodsId_Base_one: "praise.gift.x30.79_9",
            goodsName_Base_one: "x30",
            goodsPrice_Base_one: "$79.99",
        ),
        
        // ------- VIP ------- //
        
        StoreModel_Base_one(
            id_Base_one: 9,
            goodsId_Base_one: "praise.sub.1w.9_9",
            goodsName_Base_one: "Premium (1w.)",
            goodsPrice_Base_one: "$9.99",
            goodIsVIP_Base_one: true
        ),
        StoreModel_Base_one(
            id_Base_one: 10,
            goodsId_Base_one: "praise.sub.1m.19_9",
            goodsName_Base_one: "Premium (1m.)",
            goodsPrice_Base_one: "$19.99",
            goodIsVIP_Base_one: true
        ),
        StoreModel_Base_one(
            id_Base_one: 11,
            goodsId_Base_one: "praise.sub.3m.29_9",
            goodsName_Base_one: "Premium (3m.)",
            goodsPrice_Base_one: "$29.99",
            goodIsVIP_Base_one: true
        ),
        StoreModel_Base_one(
            id_Base_one: 12,
            goodsId_Base_one: "praise.sub.1y.69_9",
            goodsName_Base_one: "Premium (1y.)",
            goodsPrice_Base_one: "$69.99",
            goodIsVIP_Base_one: true
        )
    ]
    
    private override init() {
        super.init()
    }
}


extension Subscribe_Base_one {
    
    // 内购商品
    func PurchaseStoreGift_Base_one(gid_Base_one: String, completion_Base_one: @escaping() -> Void) {
        Load_Base_one.showLoading_Base_one()
        
        let products: Set = [gid_Base_one]
        RMStore.default().requestProducts(products) { success, invalidProductIdentifiers in
            RMStore.default().addPayment(gid_Base_one) { SKPaymentTransaction in
                Load_Base_one.dismissLoading_Base_one()
                if SKPaymentTransaction?.transactionState == .purchased {
                    print("支付成功")
                    Load_Base_one.showSuccess_Base_one(message_Base_one: "Payment successful")
                    
                    if (gid_Base_one.contains("praise.gift.x5.3_9")) {
                        self.isPur_Base_one = true
                    }
                    
                    NotificationCenter.default.post(name: NSNotification.Name("DazzlRefreshGifts"), object: nil)
                    completion_Base_one()
                }else{
                    print("取消支付")
                    Load_Base_one.showError_Base_one(message_Base_one: "User cancels payment")
                }
                
            } failure: { transaction, error in
                print("商品信息无效")
                Load_Base_one.showError_Base_one(message_Base_one: "Invalid product information")
            }
        } failure: { error in
            print("商品信息无效")
            Load_Base_one.showError_Base_one(message_Base_one: "Invalid product information")
        }
    }

    // 订阅VIP
    func PurchaseStoreVIP_Base_one(vipId_Base_one: String, completion_Base_one: @escaping () -> Void) {
        Load_Base_one.showLoading_Base_one()

        let products_Base_one: Set = [vipId_Base_one]
        RMStore.default().requestProducts(products_Base_one) { success, invalidProductIdentifiers in
            RMStore.default().addPayment(vipId_Base_one) { transaction_Base_one in
                Load_Base_one.dismissLoading_Base_one()
                if transaction_Base_one?.transactionState == .purchased {
                    print("VIP 支付成功")
                    Load_Base_one.showSuccess_Base_one(message_Base_one: "Payment successful")

                    NotificationCenter.default.post(
                        name: NSNotification.Name("PaneRefreshVIP"),
                        object: nil
                    )
                    completion_Base_one()
                } else {
                    print("取消 VIP 支付")
                    Load_Base_one.showError_Base_one(message_Base_one: "User cancels payment")
                }
            } failure: { transaction_Base_one, error_Base_one in
                print("VIP 商品信息无效")
                Load_Base_one.showError_Base_one(message_Base_one: "Invalid product information")
            }
        } failure: { error_Base_one in
            print("VIP 商品信息无效")
            Load_Base_one.showError_Base_one(message_Base_one: "Invalid product information")
        }
    }

    // 恢复购买
    func RestorePurchase_Base_one(completion_Base_one: @escaping () -> Void) {
        Load_Base_one.showLoading_Base_one()

        RMStore.default().restoreTransactions(onSuccess: { transactions_Base_one in
            Load_Base_one.dismissLoading_Base_one()
            if transactions_Base_one?.count == 0 {
                print("当前没有可恢复的商品")
                Load_Base_one.showError_Base_one(message_Base_one: "There are currently no items to restore")
            } else {
                print("恢复购买成功")
                Load_Base_one.showSuccess_Base_one(message_Base_one: "Restore purchase successfully")

                NotificationCenter.default.post(
                    name: NSNotification.Name("PaneRefreshVIP"),
                    object: nil
                )
                completion_Base_one()
            }
        }, failure: { error_Base_one in
            print("取消恢复购买")
            Load_Base_one.showError_Base_one(message_Base_one: "Cancel restore purchase")
        })
    }
}
