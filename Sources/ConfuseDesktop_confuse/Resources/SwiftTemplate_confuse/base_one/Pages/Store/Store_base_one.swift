import Foundation
import RMStore

// MARK: 商店数据

/// 商店数据
class Store_Base_one: NSObject {
    
    /// 单例
    static let shared_Base_one = Store_Base_one()
    
    // 礼物商品列表
    var goodsList_Base_one: [StoreModel_Base_one] = [
        StoreModel_Base_one(
            id_Base_one: 0,
            goodsId_Base_one: "wanderbell.gift.x2.1_9",
            goodsName_Base_one: "x2",
            goodsPrice_Base_one: "$1.99",
            goodIsTop_Base_one: false,
            goodIsLimit_Base_one: true
        ),
        StoreModel_Base_one(
            id_Base_one: 1,
            goodsId_Base_one: "wanderbell.gift.x3.3_9",
            goodsName_Base_one: "x3",
            goodsPrice_Base_one: "$3.99",
            goodIsTop_Base_one: false,
            goodIsLimit_Base_one: true
        ),
        StoreModel_Base_one(
            id_Base_one: 2,
            goodsId_Base_one: "wanderbell.gift.x5.4_9",
            goodsName_Base_one: "x5",
            goodsPrice_Base_one: "$4.99",
            goodIsTop_Base_one: false,
            goodIsLimit_Base_one: true
        ),
        StoreModel_Base_one(
            id_Base_one: 3,
            goodsId_Base_one: "wanderbell.gift.x1.1_9",
            goodsName_Base_one: "x1",
            goodsPrice_Base_one: "$1.99",
            goodIsTop_Base_one: false,
            goodIsLimit_Base_one: false
        ),
        StoreModel_Base_one(
            id_Base_one: 4,
            goodsId_Base_one: "wanderbell.gift.x2.2_9",
            goodsName_Base_one: "x2",
            goodsPrice_Base_one: "$2.99",
            goodIsTop_Base_one: false,
            goodIsLimit_Base_one: false
        ),
        StoreModel_Base_one(
            id_Base_one: 5,
            goodsId_Base_one: "wanderbell.gift.x3.3_9_s",
            goodsName_Base_one: "x3",
            goodsPrice_Base_one: "$3.99",
            goodIsTop_Base_one: false,
            goodIsLimit_Base_one: false
        ),
        StoreModel_Base_one(
            id_Base_one: 6,
            goodsId_Base_one: "wanderbell.gift.x4.4_9",
            goodsName_Base_one: "x4",
            goodsPrice_Base_one: "$4.99",
            goodIsTop_Base_one: false,
            goodIsLimit_Base_one: false
        ),
        StoreModel_Base_one(
            id_Base_one: 7,
            goodsId_Base_one: "wanderbell.gift.x5.6_9",
            goodsName_Base_one: "x5",
            goodsPrice_Base_one: "$6.99",
            goodIsTop_Base_one: false,
            goodIsLimit_Base_one: false
        ),
        StoreModel_Base_one(
            id_Base_one: 8,
            goodsId_Base_one: "wanderbell.gift.x10.9_9",
            goodsName_Base_one: "x10",
            goodsPrice_Base_one: "$9.99",
            goodIsTop_Base_one: false,
            goodIsLimit_Base_one: false
        ),
        StoreModel_Base_one(
            id_Base_one: 9,
            goodsId_Base_one: "wanderbell.gift.x20.19_9",
            goodsName_Base_one: "x20",
            goodsPrice_Base_one: "$19.99",
            goodIsTop_Base_one: false,
            goodIsLimit_Base_one: false
        ),
        StoreModel_Base_one(
            id_Base_one: 10,
            goodsId_Base_one: "wanderbell.gift.x30.29_9",
            goodsName_Base_one: "x30",
            goodsPrice_Base_one: "$29.99",
            goodIsTop_Base_one: false,
            goodIsLimit_Base_one: false
        ),
        StoreModel_Base_one(
            id_Base_one: 11,
            goodsId_Base_one: "wanderbell.gift.x50.49_9",
            goodsName_Base_one: "x50",
            goodsPrice_Base_one: "$49.99",
            goodIsTop_Base_one: false,
            goodIsLimit_Base_one: false
        ),
        StoreModel_Base_one(
            id_Base_one: 12,
            goodsId_Base_one: "wanderbell.gift.x70.69_9",
            goodsName_Base_one: "x70",
            goodsPrice_Base_one: "$69.99",
            goodIsTop_Base_one: false,
            goodIsLimit_Base_one: false
        ),
        StoreModel_Base_one(
            id_Base_one: 13,
            goodsId_Base_one: "wanderbell.gift.x100.99_9",
            goodsName_Base_one: "x100",
            goodsPrice_Base_one: "$99.99",
            goodIsTop_Base_one: false,
            goodIsLimit_Base_one: false
        )
    ]
    
    private override init() {
        super.init()
    }
}


extension Store_Base_one {
    
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
    
}
