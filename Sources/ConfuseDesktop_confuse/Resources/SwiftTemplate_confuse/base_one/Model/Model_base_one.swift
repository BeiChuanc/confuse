import Foundation

// MARK: 数据模型定义

/// 用户数据模型
class PrewUserModel_Base_one: NSObject, Codable {
    
    /// 用户ID
    var userId_Base_one: Int?
    
    /// 用户名字
    var userName_Base_one: String?
    
    /// 用户简介
    var userIntroduce_Base_one: String?
    
    /// 用户头像
    var userHead_Base_one: String?
    
    /// 用户媒体
    var userMedia_Base_one: [String]?
    
    /// 用户喜欢帖子列表
    var userLike_Base_one: [TitleModel_Base_one] = []

    /// 用户关注数
    var userFollow_Base_one: Int?

    /// 用户粉丝数
    var userFans_Base_one: Int?

    /// 初始化
    override init() {
        super.init()
    }
    
    /// 初始化
    init(userId_Base_one: Int? = nil,
         userName_Base_one: String? = nil,
         userIntroduce_Base_one: String? = nil,
         userHead_Base_one: String? = nil,
         userMedia_Base_one: [String]? = nil,
         userLike_Base_one: [TitleModel_Base_one] = [],
         userFollow_Base_one: Int? = nil,
         userFans_Base_one: Int? = nil) {
        self.userId_Base_one = userId_Base_one
        self.userName_Base_one = userName_Base_one
        self.userIntroduce_Base_one = userIntroduce_Base_one
        self.userHead_Base_one = userHead_Base_one
        self.userMedia_Base_one = userMedia_Base_one
        self.userLike_Base_one = userLike_Base_one
        self.userFollow_Base_one = userFollow_Base_one
        self.userFans_Base_one = userFans_Base_one
        super.init()
    }
}

/// 帖子数据模型
class TitleModel_Base_one: NSObject, Codable {
    
    /// 帖子ID
    var titleId_Base_one: Int
    
    /// 拥有者ID
    var titleUserId_Base_one: Int
    
    /// 拥有者昵称
    var titleUserName_Base_one: String
    
    /// 帖子媒体
    var titleMeidas_Base_one: [String]
    
    /// 帖子标题
    var title_Base_one: String
    
    /// 帖子内容
    var titleContent_Base_one: String
    
    /// 帖子评论列表
    var reviews_Base_one: [Comment_Base_one]
    
    /// 喜欢个数
    var likes_Base_one: Int
    
    init(titleId_Base_one: Int,
         titleUserId_Base_one: Int,
         titleUserName_Base_one: String,
         titleMeidas_Base_one: [String],
         title_Base_one: String,
         titleContent_Base_one: String,
         reviews_Base_one: [Comment_Base_one],
         likes_Base_one: Int) {
        self.titleId_Base_one = titleId_Base_one
        self.titleUserId_Base_one = titleUserId_Base_one
        self.titleUserName_Base_one = titleUserName_Base_one
        self.titleMeidas_Base_one = titleMeidas_Base_one
        self.title_Base_one = title_Base_one
        self.titleContent_Base_one = titleContent_Base_one
        self.reviews_Base_one = reviews_Base_one
        self.likes_Base_one = likes_Base_one
    }
    
}

/// 登录用户数据模型
class LoginUserModel_Base_one: NSObject, Codable {
    
    /// 用户ID
    var userId_Base_one: Int?
    
    /// 用户密码
    var userPwd_Base_one: String?
    
    /// 用户名称
    var userName_Base_one: String?
    
    /// 用户自我介绍
    var userIntroduce_Base_one: String?
    
    /// 用户头像
    var userHead_Base_one: String?
    
    /// 用户发布帖子列表
    var userPosts_Base_one: [TitleModel_Base_one]
    
    /// 用户喜欢帖子列表
    var userLike_Base_one: [TitleModel_Base_one]

    /// 用户关注列表
    var userFollow_Base_one: [PrewUserModel_Base_one]
    
    /// 初始化
    init(userId_Base_one: Int? = nil,
         userPwd_Base_one: String? = nil,
         userName_Base_one: String? = nil,
         userIntroduce_Base_one: String? = nil,
         userHead_Base_one: String? = nil,
         userPosts_Base_one: [TitleModel_Base_one],
         userLike_Base_one: [TitleModel_Base_one],
         userFollow_Base_one: [PrewUserModel_Base_one]) {
        self.userId_Base_one = userId_Base_one
        self.userPwd_Base_one = userPwd_Base_one
        self.userName_Base_one = userName_Base_one
        self.userIntroduce_Base_one = userIntroduce_Base_one
        self.userHead_Base_one = userHead_Base_one
        self.userPosts_Base_one = userPosts_Base_one
        self.userLike_Base_one = userLike_Base_one
        self.userFollow_Base_one = userFollow_Base_one
    }
}

/// 消息数据模型
class MessageModel_Base_one: Codable {
    
    /// 消息ID
    var messageId_Base_one: Int?
    
    /// 消息内容
    var content_Base_one: String?
    
    /// 用户头像
    var userHead_Base_one: String?
    
    /// 是否是我发送的
    var isMine_Base_one: Bool?
    
    /// 消息时间
    var time_Base_one: String?
    
    /// 初始化
    init(messageId_base_one: Int? = nil,
         content_base_one: String? = nil,
         userHead_base_one: String? = nil,
         isMine_base_one: Bool? = nil,
         time_base_one: String? = nil) {
        self.messageId_Base_one = messageId_base_one
        self.content_Base_one = content_base_one
        self.userHead_Base_one = userHead_base_one
        self.isMine_Base_one = isMine_base_one
        self.time_Base_one = time_base_one
    }
}

/// 评论模型
class Comment_Base_one: NSObject, Codable {
    
    /// 评论ID
    var commentId_Base_one: Int
    
    /// 评论用户uid
    var commentUserId_Base_one: Int
    
    /// 评论用户昵称
    var commentUserName_Base_one: String
    
    /// 评论内容
    var commentContent_Base_one: String
    
    /// 初始化
    init(commentId_Base_one: Int,
         commentUserId_Base_one: Int,
         commentUserName_Base_one: String,
         commentContent_Base_one: String) {
        self.commentId_Base_one = commentId_Base_one
        self.commentUserId_Base_one = commentUserId_Base_one
        self.commentUserName_Base_one = commentUserName_Base_one
        self.commentContent_Base_one = commentContent_Base_one
    }
}

/// 商店模型
class StoreModel_Base_one: NSObject {
    
    /// ID编号
    var id_Base_one: Int?
    
    /// 商品ID
    var goodsId_Base_one: String?
    
    /// 商品名字
    var goodsName_Base_one: String?
    
    /// 商品价格
    var goodsPrice_Base_one: String?
    
    /// 是否顶部商品
    var goodIsTop_Base_one: Bool?
    
    /// 是否特殊商品
    var goodIsSpecial_Base_one: Bool?
    
    /// 是否VIP商品
    var goodIsVIP_Base_one: Bool?
    
    init(id_Base_one: Int? = nil,
         goodsId_Base_one: String? = nil,
         goodsName_Base_one: String? = nil,
         goodsPrice_Base_one: String? = nil,
         goodIsTop_Base_one: Bool? = false,
         goodIsLimit_Base_one: Bool? = false,
         goodIsVIP_Base_one: Bool? = false) {
        self.id_Base_one = id_Base_one
        self.goodsId_Base_one = goodsId_Base_one
        self.goodsName_Base_one = goodsName_Base_one
        self.goodsPrice_Base_one = goodsPrice_Base_one
        self.goodIsTop_Base_one = goodIsTop_Base_one
        self.goodIsSpecial_Base_one = goodIsLimit_Base_one
        self.goodIsVIP_Base_one = goodIsVIP_Base_one
        super.init()
    }
}
