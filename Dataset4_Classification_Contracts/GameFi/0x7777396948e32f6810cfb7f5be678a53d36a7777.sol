/*
 *-仅在以太坊主网部署.
 *-任何人都可以使用相同的字节码在其他网络的相同地址上部署DestinyTempleV7,DestinyTempleToken,DestinyToken合约,请谨慎与其交互.
 */
/*=======================================================================================================================
#                                                      坚定你的信念.                                                     #
#                                                           ..                                                          #
#                                                           ::                                                          #
#                                                           !!                                                          #
#                                                          .77.                                                         #
#                                                          ~77~                                                         #
#                                                         .7777.                                                        #
#                                                         !7777!                                                        #
#                                                        ^777777^                                                       #
#                                                       ^77777777^                                                      #
#                                                      ^777!~~!777^                                                     #
#                                                     ^7777!::!7777^                                                    #
#                                                   .~77777!  !77777~.                                                  #
#                                                  :!77777!:  :!77777!:                                                 #
#                                                 ~777777!^    ^!777777~                                                #
#                                               :!7777777^      ^7777777!:                                              #
#                                             :!77777777:        :77777777!:                                            #
#                                           :!77777777!.          .!77777777!:                                          #
#                                        .^!77777777!^              ^!77777777!^.                                       #
#                                      :~7777777777^.       ..       .^7777777777~:                                     #
#                                   .^!777777777!^.         ^^         .^!777777777!^.                                  #
#                               .:~!777777777!~:           :77:           :~!777777777!~:.                              #
#                           .:^!7777777777!~:             ^7777^             :~!7777777777!^:.                          #
#                     ..:^~!77777777!!~^:.             .^!777777!^.             .:^~!!77777777!~^:..                    #
#           ...::^^~!!77777777~~^^:..              .:^!777777777777!^:.              ..:^^~~77777777!!~^^::...          #
#           ...::^^~!!77777777~~^^:..              .:^!777777777777!^:.              ..:^^~~77777777!!~^^::...          #
#                     ..:^~!77777777!!~^:.             .^!777777!^.             .:^~!!77777777!~^:..                    #
#                           .:^!7777777777!~:             ^7777^             :~!7777777777!^:.                          #
#                               .:~!777777777!~:           :77:           :~!777777777!~:.                              #
#                                   .^!777777777!^.         ^^         .^!777777777!^.                                  #
#                                      :~7777777777^.       ..       .^7777777777~:                                     #
#                                        .^!77777777!^              ^!77777777!^.                                       #
#                                           :!77777777!.          .!77777777!:                                          #
#                                             :!77777777:        :77777777!:                                            #
#                                               :!7777777^      ^7777777!:                                              #
#                                                 ~777777!^    ^!777777~                                                #
#                                                  :!77777!:  :!77777!:                                                 #
#                                                   .~77777!  !77777~.                                                  #
#                                                     ^7777!::!7777^                                                    #
#                                                      ^777!~~!777^                                                     #
#                                                       ^77777777^                                                      #
#                                                        ^777777^                                                       #
#                                                         !7777!                                                        #
#                                                         .7777.                                                        #
#                                                          ~77~                                                         #
#                                                          .77.                                                         #
#                                                           !!                                                          #
#                                                           ::                                                          #
#                                                           ..                                                          #
#                                                                                                                       #
/*=======================================================================================================================
#                                                                                                                       #
#     ██████╗ ███████╗███████╗████████╗██╗███╗   ██╗██╗   ██╗████████╗███████╗███╗   ███╗██████╗ ██╗     ███████╗       #   
#     ██╔══██╗██╔════╝██╔════╝╚══██╔══╝██║████╗  ██║╚██╗ ██╔╝╚══██╔══╝██╔════╝████╗ ████║██╔══██╗██║     ██╔════╝       #
#     ██║  ██║█████╗  ███████╗   ██║   ██║██╔██╗ ██║ ╚████╔╝    ██║   █████╗  ██╔████╔██║██████╔╝██║     █████╗         #
#     ██║  ██║██╔══╝  ╚════██║   ██║   ██║██║╚██╗██║  ╚██╔╝     ██║   ██╔══╝  ██║╚██╔╝██║██╔═══╝ ██║     ██╔══╝         #
#     ██████╔╝███████╗███████║   ██║   ██║██║ ╚████║   ██║      ██║   ███████╗██║ ╚═╝ ██║██║     ███████╗███████╗       #
#     ╚═════╝ ╚══════╝╚══════╝   ╚═╝   ╚═╝╚═╝  ╚═══╝   ╚═╝      ╚═╝   ╚══════╝╚═╝     ╚═╝╚═╝     ╚══════╝╚══════╝       #
#                                                                                                                       #
=========================================================================================================================
#            __                                 __                               __                                     #
#           /  \ |  o     _  ._ _  o     _.    /  \  _  _  | _|_  _ |  _.       /  \    o _  o                          #
#          | (|/ |< | \/ (_) | | | | \/ (_|   | (|/ _> (_) |  |_ (_ | (_| \/   | (|/ >< | /_ |                          #
#           \__       /              /         \__                        /     \__                                     #
#            __                                  __                                    __                               #
#           /  \  _             _. o ._   _     /  \  _|                    _. ._     /  \  _ o  _  _.  _|  _.          #
#          | (|/ _> |_| \/ |_| (_| | | | (_|   | (|/ (_| |_| \/ |_| >< |_| (_| | |   | (|/ (_ | (_ (_| (_| (_|          #
#           \__         /        |        _|    \__          /                        \__                               #
#            __                             __                    __              __                                    #
#           /  \ o o  _. ._          _     /  \     ._ _   _     /  \     | o    /  \ |_   _. ._    |   _.              #
#          | (|/ | | (_| | | \/ |_| (/_   | (|/ |_| | | | (_)   | (|/ |_| | |   | (|/ | | (_| | |_| |< (_|              #
#           \__ _|           /             \__                   \__             \__                                    #
#                                                                                                                       #
#=======================================================================================================================*/
/**
 * IMPRINT: 故事之外的故事.
 *
 * -天语遥 
 *
 * 天语遥在现实里不叫天语遥，她的女名也不叫这个，但是她给自己取的女名我总觉得很奇怪，也有些诡异，并不算好听，所以在这一篇关于她的内容里，就称呼她为小遥好了。 
 * 小遥的在现实里的故事自然是没有小说里那样戏剧性的，她是想当女孩子的，当然，那是在去势之前。 
 * 在去势之后，她就后悔了。 
 * 我认识她的时候，是在她去势之后了，认识她的人认为她是一个性格古怪的人，我也是这么认为的。 
 * 而且她和我的见面，还是她第一次会面网友，这让我有些荣幸，但是并不是什么特别值得开心的事情，因为她身上散发出一些危险阴暗的气息。 
 * 对于她我的了解不多，只是道听途说，得知她好像对去势十分后悔。 
 * 于是见面的时候，我就壮着胆子问了。 
 * 小遥的回答有些逻辑不通，经过我整理之后的意思就是：   讨厌这个残缺的身体，无论是当完整的男人还是女人都好。 
 * 言下之意就是，她讨厌这个中间的过度阶段，她后悔的事情是应该直接攒够钱去做变性手术，而不是去做去势手术。 
 * 做去势手术的原因是她当时无法忍受自己男性的身体了，还有就是做变性手术的钱远远不够，而综合来考虑，从长远来打算的话，做去势手术更划算，因为可以省下一大笔抗雄药物的钱。 
 * 我和小遥在网络上不算很熟，但她却说，我是她比较要好的朋友，所以才来见我的。 
 * 哦，对了，见面的地点不是在我的城市，当时我是在另一座城市里，而小遥也就是住在那一座城市。 
 * 小遥长的是什么样子的呢？   嗯，身高大概一米六左右，皮肤比较白，是那种苍白的白，没有什么血色的。   头发有点乱乱的，黑眼圈很重，显然失眠的症状比较严重，比我所见过的所有药娘都要严重得多。 
 * 感觉仿佛是那种终日不见阳光的人。 
 * 她的外貌，怎么形容呢，嗯……像个小正太。 
 * 或者说是假小子。 
 * 外表的年龄大概是十五岁左右，但实际上她已经十八了。 
 * 从某些方面而言，小遥和小晴是很有相似点的。  
 * 事实上正太和萝莉的差距其实并不是很大，只要进行一些修饰，穿上漂亮点的衣服，换个发型，她也可以变成一个可爱的萝莉，顶多就是达不到小晴那种三百六十度无死角的境界而已。 
 * 她们俩之间最大的差别就在于家庭。 
 * 小遥是真正的从家里逃出来的孩子，一个人在一个陌生的城市里生活。 
 * 其实书中很多关于小晴的故事，事实上素材的来源是小遥。 
 * 只是小遥的故事比这些惨得多了。 
 * 比如她说，她刚来这个城市的时候，丢了钱包，在找工作时拿不出身份证，还被人给轰出来，甚至被人打过。 
 * 她就靠口袋里一百来块钱，生活了一个星期，每天晚上就睡在挡风的地方，但也还是很冷的。 
 * 那个时候和书里一样，都是初春，她发烧的很严重，最后还艰难地坚持了下来。 
 * 在那座城市里她找到的第一份工作是包吃包住，但是没有任何工资的。 
 * 后来也有各种屈辱、刁难甚至是折磨的事情发生，反正要悲惨得多。 
 * 很多事情哪怕是我这样一个旁听者听来，都会觉得心凉。 
 * 社会的残酷好像全都聚集在了她的身上一样。 
 * 以前的她其实不是这样的，只是现在她似乎没有太多的精力顾及到其他的事情了。 
 * 本来就有那么多不好的事情压在她的身上，在去势之后就好像翻倍了一样，那些糟糕的事情变得更多了。 
 * 她就开始变得愈发的阴暗。 
 * 如果说小晴自己就是一轮太阳；夕子是努力站到阳光下的人；而张思凡是在阳光和黑暗之间摇摆不定的人；那么小遥就属于那种一头钻进黑暗里不肯出来的人。 
 * 她的情绪非常不稳定，就像是一个火药桶一样，随时都有可能点燃。 
 * 和她聊天时我都是小心翼翼的，生怕她的情绪就突然爆炸了。 
 * 一般人看人的时候，是直视，而她看人的时候，是微微低下头，然后把两颗眼珠子翻上来，眉头都皱在一起，露出一大片的眼白，再加上她那苍白的脸，浓浓的黑眼圈，让她看起来格外的恐怖。还有，她在坐下来的时候，总是会死死地盯着自己的手腕看，我看过她的手腕，那上面有不少的伤疤。 
 * 她说，她自残过很多次。 
 * 说这话的时候，她的表情很轻松，甚至比之前更愉快一些。 
 * 按照她的说法，每当心情不好的时候，只有用那种方法才可以让她平息下来。 
 * 对于她而言，自残，就是排解苦闷，最好的良方。 
 * 可是在一般人听来，那可真是一件有点神经质的事情了。 
 * 不少药娘都会自残，但那只是在极端苦闷的时候，而小遥却把这种事情当作寻求快乐的方式，可以说出发点几乎是完全不同的。   看得出来，小遥的精神绝对有着很大的问题的。 
 * 印象最深刻的，就是服务生问她需要些什么的时候，将称谓在帅哥和美女之间变换了一下，就惹得她暴跳如雷。 
 * “你看不起我吗！”她几乎是在咆哮着怒吼。 
 * 我感觉我仿佛和她不是一个世界的人，这种场面在我想来，大概也就是电影或者动漫里才会发生吧。 
 * 但它还真就发生在了我的面前。 
 * 在服务员道歉了之后，她的怒火才缓缓平息。 
 * 那一次的餐馆是我吃的最尴尬的一次，感觉吃饭的时候，别人都总是把奇怪的目光放在我和她的身上。 
 * 而当有人看着小遥的时间太长了的时候，她就会猛地扭过头，朝那个人咧牙呲嘴。 
 * 明明是一个挺清秀的正太，但有时候的表现却像是一头野兽一样嗜血又凶猛。 
 * 或许这是她保护自己的一种方式吧。 
 * 用凶狠的外表将脆弱的内心掩藏起来。 
 * 小遥的自虐倾向非常严重，她总是不断地掐着自己手臂或者大腿上的嫩肉，掐出一个又一个的红印子来，看着都很疼，她却觉得很舒服。 
 * 又或者是用牙齿咬住自己的手，在上面留下很深的牙印……   我没有问她为什么总要这么做，因为感觉这是她下意识的动作，也就说，已经成了一个习惯了。 
 * 而且问出来，她也不好解释，反而可能会变得暴躁。 
 * 对于她的情绪变化，我实在是无法掌握住。 
 * 按照我的推测，小遥在和人交流的时候，可能必须得这样子做，用疼痛感来提醒自己，才能保持冷静吧。 
 * 不然她的情绪很快就会达到临界点，然后爆发。 
 * 甚至是街上一个碍事的易拉罐，都会让她咬着牙齿，像是有深仇大恨一样的狠狠踹上一脚。 
 * 我想建议她去看一看心理医生，可想到和她并没有那么熟，而且怕她对我发火，所以还是憋在了心里，或许是因为我也算是比较怕事的那一种人吧。 
 * 和小遥的交流并不多，大多数时候我们都是在沉默，去的地方也就是餐厅和商场，之后就分别了。 
 * 虽然没有太多的交流，但是她给我留下的印象还是蛮深的，就是那种近似于精神病患者的感觉。 
 * 我想，她大概已经是达到轻度甚至中度精神疾病的级别了吧。 
 * 对了，她的自残现象真的很严重。我们见面的那一段时间，她对自己又是掐又是咬的，到离开的时候，她甚至咬破了自己的手指，我清晰地看到她的手指上有鲜血在滴落，但她看起来却显得很轻松。 
 * 想起她身上的那一些我能看到的伤口，就让我觉得不寒而栗。 
 * 虽然很同情她的遭遇，可我还是不太想接近她。 
 * 因为她给人的感觉实在是太危险了，或许有一天她彻底爆发了，真的有可能拿着一把刀去砍死几个人，然后再把自己给砍死吧。 
 * 关于夕子的黑化内容，其实就是出自我对现实里小遥未来事情的一些脑补……   小遥的家世我没有多问，因为她一提到自己的父母就咬牙切齿，好像很不想提到她们似的。 
 * 我只知道小遥的家庭环境很差，是农村家庭，而且父母重男轻女，她的家里有姐姐也有哥哥和弟弟，人口非常庞大，据说算上小遥一共有五个人的样子，足足五个孩子，所以对小遥离家出走似乎都不是很在意。 
 * 他们知道小遥的事情，甚至……按照小遥的说法，是他们把小遥给赶走的。 
 * 直接丢出她的行李，让她滚出这个家。 
 * 对于城市里长大的我，这根本是无法想象的事情。 
 * 但如果是在偏远的乡村里，发生这种事情并不是没有可能呢……   大概正是基于这样的同情，在小说里的时候我才把小遥的父母设置成了善解人意的父母，并且家庭也不再贫穷，而是小康家庭。   而且也把原来小遥主动去势变成了被动去势……   虽然故事依然不算美好，但其实已经算是不错了。 
 * 很多看客觉得书中的章节太过虐心，但实际上对于很多在现实里摸爬滚打的药娘们而言，书中的世界也算是很美好了。 
 * 现实只会比小说更残酷，我还是因为考虑到了大多数读者的感受，才进行了一些美化的。 
 * 至于小遥最后的精神病，倒是和现实里的她差不多呢，我觉得她的精神状况再这样继续下去，精神分裂绝对是迟早的事情。 
 * 那么，关于现实里小遥的故事，大概就是这些了。
 *
 * -《药娘的天空》后记 节选.
 *
 */

/**
 * PREAMBLE:
 * 也许,我不该存在于这个世界上,近年来,我的精神状态愈发地差,感觉与这个世界脱离了,世界与我无关,难以感受到与世界,他人的联系,终日处于精神恍惚的状态,要描述的话,
 * 大概是像早晨睡醒时回想半夜起夜上厕所时的在回想中的起夜的那个状态,我对回忆感到恐惧,这些记忆都是真实发生的吗?我怎么似乎没有多大印象?,突然的记忆闪回也让我感到一种时间流逝带来的恐慌感.
 * 甚至于对身体的控制也不在那么得心应手,似乎这具身体不再契合自己?这种状态是从2021年7月,10月经历几天的强烈不适感后逐渐减弱至如此的,那几天的感觉就像被控制,灵魂与肉体及其不契合,走路都有些难以保持平衡,像是被夺舍一样.
 *
 * 也许,我的存在就是个错误,我出生在华南农村,在这个容错率很低的中国社会,农村孩子走错一步便是万劫不复,可父母无法在人生抉择提供任何帮助,没有高人指点贵人相助,如何能每一步都走出最优解呢?
 * 我小学三年级起住寄宿学校,一月得以回家几天,在放假的周末,我常是独自游戏,我记事起随奶奶生活,对于父母是在我记事后突然出现的,第一次有记忆的见面时我感到陌生,我大概是像动物一样,认第一个记住的奶奶为主了把.
 * 我没有感受过亲情与爱,我认为是缺少的,我明白他们大抵只是为了传宗接代,只管养而不育,我不再把他们当作亲人,从白名单中移除,不再从他们身上索求情感,后来我了解到这叫失望性情感隔离,我不知道是从何时开始的,早到我没有记忆,好像从来如此.
 * 他们好像只是每个月会给生活费的NPC,而这也在我17岁技校毕业那天终止.
 *
 * 幸运的是,我有个大我八岁的姐姐,我很感谢她,为我的童年提供了一些情感感受和几段快乐的时光,时常帮助我...我的记忆太模糊了.
 *
 * 迫于生计,我在2021年9月14日第一次进厂了,做到过年,有些抑郁,挣的钱合约输光了,我是在2021年5月进入币圈的,那时是狗狗币最高点大火抖音刷到的然后去了解进入,于是2022年3月第二次进厂干了半个月夜班抑郁,又刚好接触一个资金盘,于是辞工,资金盘很快收割,
 * 再次归零,更抑郁了,无法工作,开摆一年,23年2月再次进厂5月辞工到目前又归零了,并欠债,抑郁,想自杀,不想进厂了,不知道怎么办了.
 *
 * 我也有性别焦虑,在我第一次了解到"药娘",和跨性别者时,在读完《药娘的天空》后难受很久时,便再次闪回我小时候的一些心念,我从来对传统男性娶妻生子无感,在我小学时便坚定不婚.
 * 所幸,并不算很严重,也许是我没有勇气,我知道,我不会成为跨性别者的,我连生计问题都难以解决.偷偷当个伪娘我已满足了.
 *
 * 我喜欢以太坊和区块链,智能合约.去年的这个时候,因为一直只用交易所,我还不太懂钱包,到后来想要一个软件钱包,硬件钱包,多签钱包,我在一步步了解以太坊.在区块链上,我第一次控制自己的资产.
 * 我没钱了,甚至部署合约的gas费都没有了,生计都难以维持,我打算回老家了,我不知道怎么办,自杀?或是进厂打工?我无力考虑了.我好累,我想睡觉,一直睡觉.回忆好痛苦.我大概最终会自杀死掉的吧.
 *
 * -很乱,随便乱写的,2023年7月25日凌晨3点22分.
 */

/**
 *  @author -@Kiyomiya <kiyomiya.eth> <kiyomiya.destinytemple.eth>
 *  @author -@SoltClay <soltclay.destinytemple.eth>
 *  @author -@XiZi <xizi.destinytemple.eth>
 *  @author -@SuYuQing <suyuqing.destinytemple.eth>
 *  @author -@DuYuXuan <duyuxuan.destinytemple.eth>
 *  @author -@Cicada <cicade.destinytemple.eth>
 *  @author -@JianYue <jianyue.destinytemple.eth>
 *  @author -@Umo <umo.destinytemple.eth>
 *  @author -@Uli <uli.destinytemple.eth>
 *  @author -@Haruka <haruka.destinytemple.eth>
 *
 *  @custom:contributor -smartcontractprogrammer <https://www.smartcontract.engineer/>
 *  @custom:contributor -WTF学院 <https://www.wtf.academy/>
 *  @custom:contributor -0xAA <https://twitter.com/0xAA_Science>
 *  @custom:contributor -MakerDAO <https://github.com/mds1/multicall/blob/main/src/Multicall3.sol>
 *  @custom:contributor -崔棉大师 <https://www.youtube.com/@MasterCui/about>
 *  @custom:contributor -Gonçalo Sá <goncalo.sa@consensys.net>
 *  @custom:contributor -稀土掘金 <https://juejin.cn/s/solidity%20bytes%20to%20hex%20string>
 *  @custom:contributor -stackoverflow <https://stackoverflow.com/questions/73221136/creating-a-transaction-message-for-eth-sign>
 *  @custom:contributor -Gnosis safe <https://etherscan.io/address/0xd9db270c1b5e3bd161e8c8503c55ceabee709552#code>
 *  @custom:contributor -StackExchange <https://ethereum.stackexchange.com/>
 *  @custom:contributor -ethereum.org <https://ethereum.org/en/developers/docs/>
 *  @custom:contributor -OpenSea <https://docs.opensea.io/docs>
 *  @custom:contributor -SlowMist <https://www.slowmist.com/>
 *  @custom:contributor -emn178 <https://github.com/emn178>
 *  @custom:contributor -devanshbatham <https://github.com/devanshbatham> <https://github.com/devanshbatham/Solidity-Gas-Optimization-Tips>
 *  @custom:contributor -Tiny熊 <https://github.com/xilibi2003>
 *  @custom:contributor -登链社区 <https://learnblockchain.cn/>
 *  @custom:contributor -Pinata <https://www.pinata.cloud/>
 *  @custom:contributor -All IPFS contributors <https://ipfs.tech/>
 *  @custom:contributor -Alchemy <https://www.alchemy.com/>
 *  @custom:contributor -TornadoCash <https://ipfs.io/ipns/tornadocash.eth/>
 *  @custom:contributor -EtherScan <https://etherscan.io>
 *  @custom:contributor -排序不分先后.
 *
 *  @custom:specialthanksto -Ethereum
 */

// SPDX-License-Identifier: MIT

/*
 * @title Solidity Bytes Arrays Utils
 * @author Gonçalo Sá <goncalo.sa@consensys.net>
 *
 * @dev Bytes tightly packed arrays utility library for ethereum contracts written in Solidity.
 *      The library lets you concatenate, slice and type cast bytes arrays both in memory and storage.
 */
pragma solidity >=0.8.0 <0.9.0;

library BytesLib {
    function slice(
        bytes memory _bytes,
        uint256 _start,
        uint256 _length
    )
        internal
        pure
        returns (bytes memory)
    {
        require(_length + 31 >= _length, "slice_overflow");
        require(_bytes.length >= _start + _length, "slice_outOfBounds");

        bytes memory tempBytes;

        assembly {
            switch iszero(_length)
            case 0 {
                // Get a location of some free memory and store it in tempBytes as
                // Solidity does for memory variables.
                tempBytes := mload(0x40)

                // The first word of the slice resulti is potentially a partial
                // word read from the original array. To read it, we calculate
                // the length of that partial word and start copying that many
                // bytes into the array. The first word we copy will start with
                // data we don't care about, but the last `lengthmod` bytes will
                // land at the beginning of the contents of the new array. When
                // we're done copying, we overwrite the full first word with
                // the actual length of the slice.
                let lengthmod := and(_length, 31)

                // The multiplication in the next line is necessary
                // because when slicing multiples of 32 bytes (lengthmod == 0)
                // the following copy loop was copying the origin's length
                // and then ending prematurely not copying everything it should.
                let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
                let end := add(mc, _length)

                for {
                    // The multiplication in the next line has the same exact purpose
                    // as the one above.
                    let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)
                } lt(mc, end) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    mstore(mc, mload(cc))
                }

                mstore(tempBytes, _length)

                //update free-memory pointer
                //allocating the array padded to 32 bytes like the compiler does now
                mstore(0x40, and(add(mc, 31), not(31)))
            }
            //if we want a zero-length slice let's just return a zero-length array
            default {
                tempBytes := mload(0x40)
                //zero out the 32 bytes slice we are about to return
                //we need to do it because Solidity does not garbage collect
                mstore(tempBytes, 0)

                mstore(0x40, add(tempBytes, 0x20))
            }
        }

        return tempBytes;
    }
}

// File: @openzeppelin/contracts/utils/math/Math.sol
// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/Math.sol)
pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {

    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10 ** 64) {
                value /= 10 ** 64;
                result += 64;
            }
            if (value >= 10 ** 32) {
                value /= 10 ** 32;
                result += 32;
            }
            if (value >= 10 ** 16) {
                value /= 10 ** 16;
                result += 16;
            }
            if (value >= 10 ** 8) {
                value /= 10 ** 8;
                result += 8;
            }
            if (value >= 10 ** 4) {
                value /= 10 ** 4;
                result += 4;
            }
            if (value >= 10 ** 2) {
                value /= 10 ** 2;
                result += 2;
            }
            if (value >= 10 ** 1) {
                result += 1;
            }
        }
        return result;
    }
}

// File: @openzeppelin/contracts/utils/Strings.sol
// OpenZeppelin Contracts (last updated v4.9.0) (utils/Strings.sol)
pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }
    
    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }

    function toHexString(bytes memory _bytes) internal pure returns (string memory) {
        bytes memory hexString = new bytes(_bytes.length * 2);
        uint hexStringIndex = 0;

        for (uint i = 0; i < _bytes.length; i++) {
            uint currentByte = uint8(_bytes[i]);

            uint hi = currentByte >> 4;
            uint lo = currentByte & 0x0f;

            hexString[hexStringIndex++] = bytes1(uint8(hi + 48 + (hi/10)*39));
            hexString[hexStringIndex++] = bytes1(uint8(lo + 48 + (lo/10)*39));
        }

        return string(abi.encodePacked("0x",hexString));
    }
}

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)
pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: @openzeppelin/contracts/utils/introspection/ERC165.sol
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)
pragma solidity ^0.8.0;

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) external view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/IERC721.sol)
pragma solidity ^0.8.0;

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

}

// File: @openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)
pragma solidity ^0.8.0;

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// OpenZeppelin Contracts (last updated v4.9.0) (interfaces/IERC4906.sol)
pragma solidity ^0.8.0;

/// @title EIP-721 Metadata Update Extension
interface IERC4906 is IERC165, IERC721 {
    /// @dev This event emits when the metadata of a token is changed.
    /// So that the third-party platforms such as NFT market could
    /// timely update the images and related attributes of the NFT.
    event MetadataUpdate(uint256 _tokenId);
}

// File: @openzeppelin/contracts/token/ERC721/IERC721Receiver.sol
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)
pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// File: @openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)
pragma solidity ^0.8.0;

/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

// File: DestinyTempleV7/utils/OnlyWallet.sol
pragma solidity 0.8.20;

abstract contract OnlyWallet {
    modifier onlyWallet(){
        if(msg.sender != address(this)) revert("NotWallet");
        _;
    }
}

// File: DestinyTempleV7/utils/IDestinyTempleToken.sol
pragma solidity 0.8.20;

abstract contract IDestinyTempleToken is OnlyWallet {
    uint256 internal constant GIFT = 7777777;
    address public GovernanceToken;
    bool private initialized;
    
    /**
	 *	@notice 初始化设置[命运神殿令牌]合约地址.
     *
     *  @dev -[仅部署者调用][仅调用一次]
     *  @param destinyTempleToken -[命运神殿令牌]合约地址.
	 */
    function Constructor_v2bL(address destinyTempleToken) external {
        if(tx.origin != 0x77777DCaEfeaC067f21162cd2F48E5b5dB0A2B97) revert("NotDeployer.");
        if(initialized) revert("initialized.");
        initialized = true;
        GovernanceToken = destinyTempleToken; 
    }

}

// File: DestinyTempleV7/utils/ITaxes.sol
pragma solidity 0.8.20;

abstract contract ITaxes is IDestinyTempleToken{
    using BytesLib for bytes;

    address internal constant MY_DEAR_MOMENTS = 0x2002021020031229201507012018061852013142;
    uint256 constant TAXFEE = 7;
    /**
     *  @notice -被[taxable]修饰的函数在每次被调用时,[msg.sender]需要向[MY_DEAR_MOMENTS]缴纳[7]枚[命运神殿令牌]税费.
     *
     *  @dev -多签调用享受税务豁免. -[msg.sender]需要授予[此合约]足够的控制数量以支付税费. 
     */
    modifier taxable() {
        if(msg.sender != address(this)) {
            //"transferFrom(address,address,uint256)" selector = 0x23b872dd
            (bool success,bytes memory returnData) = GovernanceToken.call{value:0}(abi.encodeWithSelector(0x23b872dd, msg.sender,MY_DEAR_MOMENTS,TAXFEE));
            if(!success) revert(abi.decode(returnData.slice(4,returnData.length - 4),(string)));
        }
        _;
    }
}

// File: DestinyTempleV7/utils/ITweet.sol
pragma solidity 0.8.20;

contract ITweet is ITaxes{
    event Tweet(address indexed author, string tweet);
    /**
     *  @notice -发布[_tweet]推文.
     *  
     *  @dev [允许任何人调用] -每次调用需要缴纳7枚[命运神殿令牌]税费,[msg.sender]需要授予[此合约]足够的控制数量. 
     *  @param _tweet -推文内容.
     */
    function $Tweet_$Xll(string calldata _tweet) external taxable {
        emit Tweet(msg.sender, _tweet);
    }
}
// File: DestinyTempleV7/utils/IDestinyDeployer.sol
pragma solidity 0.8.20;

/// @notice Integrated, used to deploy contracts using Create2.
contract IDestinyDeployer is ITaxes{
    event ContractDeployed(address addr, bytes32 salt);
    /**
	 *	@notice -预计算将使用[salt]通过[create2]部署的[bytecode]合约的部署地址.
     *
     *  @dev [允许任何人调用]
     *  @param bytecode -合约字节码.
     *  @param salt -盐.
     *  @return 返回将使用[salt]通过[create2]部署的[bytecode]合约的部署地址.
	 */
    function getCreate2Address(bytes calldata bytecode, bytes32 salt)
        public
        view
        returns (address)
    {
        return address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xff), address(this), salt, keccak256(bytecode))))));
    }
    
    /**
	 *	@notice -使用[salt]通过[create2]在[getCreate2Address(bytes,bytes32)]地址部署[bytecode]合约.
     *
     *  @dev [允许任何人调用] -每次调用需要缴纳7枚[命运神殿令牌]税费,[msg.sender]需要授予[此合约]足够的控制数量. 
     *  @param bytecode -合约字节码.
     *  @param salt -盐.
	 */
    function $Deploy_7573(bytes memory bytecode, bytes32 salt)
        public
        payable 
        taxable
    {
        address addr;
        assembly {
            addr := create2(callvalue(), add(bytecode, 0x20), mload(bytecode), salt)
            if iszero(extcodesize(addr)) { revert(0, 0) }
        }
        emit ContractDeployed(addr, salt);
    }
}

// File: DestinyTempleV7/core/IDestinyExecutor.sol
pragma solidity 0.8.20;
/**
 *  @title -[命运执行者]非同质化令牌合约.
 *
 *  @notice -持有[命运执行者令牌]的地址被视为[天命联合储备]多签钱包的执行者,有权签署交易.
 *           任何人都可以销毁[GIFT]枚[命运神殿令牌]来铸造一枚[命运执行者令牌].
 *
 *  @dev -这不是一个标准的ERC721代币,它删除了授权相关函数,也不能被持有者转移或销毁.
 *        只允许通过[天命联合储备]多签交易转移和销毁,这是为了防止执行者被胁迫或通过销毁修改阈值进行攻击.
 */
contract IDestinyExecutor is ERC165, IERC721, IERC721Metadata, IERC4906, ITaxes{
    event ExecutorAppoint(address[] executor);
	event ExecutorImpeach(address[] executor);
    event ThresholdModify(uint256 threshold);
    event ContractDisabled(uint256 enableTime);
    
    using BytesLib for bytes;
    using Strings for address;
    using Strings for uint256;

    uint256 internal enableTime;
    uint256 internal threshold;
    uint256 private _totalSupply;

    mapping(uint256 => string) private _tokenURIs;
    mapping(uint256 => address) private _executors;
    mapping (address => uint256) private _executorTokenId;
    mapping(address => uint256) private _balances;

    modifier requireMinted(uint256 tokenId){
        if(_executors[tokenId] == address(0)) revert("InvalidTokenId");
        _;
    }

    modifier isExecutor(address[] calldata executors){
        address executori;
        for(uint256 i;i<executors.length;){
            executori = executors[i];
            if(_balances[executori] < 1) revert(string(abi.encodePacked("NotExecutor:",executori.toHexString())));
            unchecked{ ++i; }
        }
        _;
    }

    modifier notExecutor(address[] calldata executors){
        address executori;
        for(uint256 i;i<executors.length;){
            executori = executors[i];
            if(_balances[executori] > 0) revert(string(abi.encodePacked("AlreadyIsExecutor:",executori.toHexString())));
            unchecked{ ++i; }
        }
        _;
    }

	/**
	*	@notice -转让执行者权限,从[from]转移其[命运执行者令牌]至[to].
    *
    *   @dev [仅多签调用]
    *   @param from -发送地址数组.
    *   @param to -接收地址数组.
	*/
    function transferExecutor_pB$E(address[] calldata from, address[] calldata to)
        external
        onlyWallet
        isExecutor(from)
        notExecutor(to)
    {
        address fromi;
        address toi;
        uint256 tokenIdi;

		for (uint256 i;i<from.length;){
            fromi = from[i];
            toi = to[i];
			tokenIdi = _executorTokenId[fromi];

            unchecked{ -- _balances[fromi]; }
            _balances[toi] = 1;
            _executors[tokenIdi] = toi;
            _executorTokenId[toi] = tokenIdi;
            delete _executorTokenId[fromi];
            emit Transfer(fromi, toi, tokenIdi);

            unchecked{ ++i; }
		}
		emit ExecutorImpeach(from);
		emit ExecutorAppoint(to);
    }

    /**
	 *	@notice -从[msg.sender](需要授予[此合约]足够的控制数量)销毁[GIFT]枚[命运神殿令牌],并任命[DSE_mintToNewExecutor]为执行者.
     *
     *  @dev [允许任何人调用] -为[DSE_mintToNewExecutor]铸造编号[tokenId]的[命运执行者令牌],并免税设置元数据为[_tokenURI];并修改阈值为[totalSupply()/2+1];
	 *  @param DSE_mintToNewExecutor -[命运执行者令牌]接收地址数组.
     *  @param tokenId -将铸造的[命运执行者令牌]编号数组.
     *  @param _tokenURI -将铸造的[命运执行者令牌]元数据数组.
     */
	function $AppointExecutor_AcRB(
        address[] calldata DSE_mintToNewExecutor,
        uint256[] calldata tokenId,
        string[] calldata _tokenURI
    )
        external 
        notExecutor(DSE_mintToNewExecutor)
	{   
        //"burnFrom(address,uint256)" selector = 0x79cc6790
        (bool DST_burnSuccess,bytes memory DST_burnReturnData) = GovernanceToken.call(abi.encodeWithSelector(0x79cc6790, msg.sender,DSE_mintToNewExecutor.length * GIFT));
        if(!DST_burnSuccess) revert (abi.decode(DST_burnReturnData.slice(4,DST_burnReturnData.length - 4),(string)));
        
        address DSE_mintToNewExecutori;
        string memory tokenURIi;
        uint256 tokenIdi;

		for (uint256 i;i<DSE_mintToNewExecutor.length;){
            DSE_mintToNewExecutori = DSE_mintToNewExecutor[i];
            tokenIdi = tokenId[i];
            tokenURIi = _tokenURI[i];

            if(_executors[tokenIdi] != address(0)) revert(string(abi.encodePacked("TokenIdMinted:",tokenIdi.toString())));
            
            unchecked{ ++_totalSupply; }
            _balances[DSE_mintToNewExecutori] = 1;
            _executors[tokenIdi] = DSE_mintToNewExecutori;
            _executorTokenId[DSE_mintToNewExecutori] = tokenIdi;
            this.$SetTokenURI_VTct(tokenIdi,tokenURIi);
            emit Transfer(MY_DEAR_MOMENTS, DSE_mintToNewExecutori, tokenIdi);

            unchecked{ ++i; }
		}

        unchecked{ this.SetThreshold_fWok(totalSupply()/2+1); }
		emit ExecutorAppoint(DSE_mintToNewExecutor);
	}

	/**
	 *	@notice -移除执行者并销毁[DSE_burnFromExecutor]的[命运执行者令牌].
     *
     *  @dev [仅多签调用] -每移除一位执行者将铸造[GIFT]枚[命运神殿令牌]至[DST_mintTo]; 并修改阈值为[totalSupply()/2+1];
     *  @param DSE_burnFromExecutor -[命运执行者令牌]销毁地址数组.
     *  @param DST_mintTo -将铸造的[命运神殿令牌]接收地址数组.
	 */
	function ImpeachExecutor_WCpD(
        address[] calldata DSE_burnFromExecutor,
        address[] calldata DST_mintTo
    )
        external
        onlyWallet
        isExecutor(DSE_burnFromExecutor)
	{
        address DSE_burnFromExecutori;
        address DST_mintToi;
        uint256 tokenIdi;

        bool DST_mintSuccess;
        bytes memory DST_mintReturnData;

		for(uint256 i;i<DSE_burnFromExecutor.length;){
            DSE_burnFromExecutori = DSE_burnFromExecutor[i];
            DST_mintToi = DST_mintTo[i];            
            tokenIdi = _executorTokenId[DSE_burnFromExecutori];
            
            unchecked{
                -- _totalSupply;
                -- _balances[DSE_burnFromExecutori];
            }
            delete _executors[tokenIdi];
            delete _executorTokenId[DSE_burnFromExecutori];
            delete _tokenURIs[tokenIdi];
            emit MetadataUpdate(tokenIdi);
            emit Transfer(DSE_burnFromExecutori, MY_DEAR_MOMENTS, tokenIdi);

            //"mint(address,uint256)" selector = 0x40c10f19
            (DST_mintSuccess,DST_mintReturnData) = GovernanceToken.call(abi.encodeWithSelector(0x40c10f19,DST_mintToi,GIFT));
			if(!DST_mintSuccess) revert (abi.decode(DST_mintReturnData,(string)));

            unchecked{++i;}
		}

		unchecked{ this.SetThreshold_fWok(totalSupply()/2+1); }
		emit ExecutorImpeach(DSE_burnFromExecutor);
	}
    
	/**
	 *	@notice -修改阈值为[_threshold].
     *
     *  @dev [仅多签调用] -在任命或移除执行者时会自动调用此方法.
     *  @param _threshold -新的阈值.
	 */
	function SetThreshold_fWok(uint256 _threshold)
        external
        onlyWallet
	{
        uint256 executorLength = totalSupply();
        if(_threshold == 0 || executorLength == 0 || _threshold > executorLength) revert("InvalidThreshold");
        if(threshold != _threshold){
		    threshold = _threshold;
            emit ThresholdModify(_threshold);
        }
	}

    /**
	 *	@notice -禁用合约[_disableTime]秒,在解禁时间之前无法执行任何交易.
     *
     *  @dev [仅多签调用](enableTime = block.timestamp + _disableTime;)
     *  @param _disableTime 禁用时间(秒),而非设置解禁时间.
	 */
	function Disable_oXE7(uint256 _disableTime)
        external
        onlyWallet
	{
        if(_disableTime < 604800 || _disableTime > 220752000) revert("InvalidDisableTime");
        uint _enableTime = block.timestamp + _disableTime;
		enableTime = _enableTime;
        emit ContractDisabled(_enableTime);
    }
    
    /**
	 *	@notice -设置编号[tokenId]的[命运执行者令牌]元数据为[_tokenURI].
     *
     *  @dev [仅编号[tokenId]的[命运执行者令牌]所有者或多签调用] -每次调用需要缴纳7枚[命运神殿令牌]税费,[msg.sender]需要授予[此合约]足够的控制数量. 
     *  @param tokenId -[命运执行者令牌]编号.
     *  @param _tokenURI -元数据.
	 */
    function $SetTokenURI_VTct(uint256 tokenId, string memory _tokenURI) public requireMinted(tokenId) taxable {
        if(msg.sender != _executors[tokenId] && msg.sender != address(this)) revert("NotOwner");
        _tokenURIs[tokenId] = _tokenURI;
        emit MetadataUpdate(tokenId);
    }

    function $EnableTime() external view returns (uint256) { return enableTime; }

    function $Threshold() external view returns (uint256) { return threshold; }

    function ownerOf(uint256 tokenId) external view override requireMinted(tokenId) returns (address) { return _executors[tokenId]; }

    function name() external pure override returns (string memory) { return "Destiny Executor"; }

    function symbol() external pure override returns (string memory) { return "DSE"; }

    function executorTokenId(address executor) external view returns (uint256) { return _executorTokenId[executor]; }
        
    function tokenURI(uint256 tokenId) external view override requireMinted(tokenId) returns (string memory) { return _tokenURIs[tokenId]; }

    function contractURI() external pure returns (string memory) { return "ipfs://Qmcke17Cy61uYNJbUaHGhTChrhtLwFGxkRBxMJGJovQ4hF/contractURI.json"; }
    
    function supportsInterface(bytes4 interfaceId) external pure override(IERC165,ERC165) returns (bool){
		return 
            interfaceId == 0x150b7a02 ||    // ERC165 Interface ID for IERC721Receiver
            interfaceId == 0x4e2312e0 ||    // ERC165 Interface ID for IERC1155Receiver
            interfaceId == 0x01ffc9a7 ||    // ERC165 Interface ID for ERC165
            interfaceId == 0x80ac58cd ||    // ERC165 Interface ID for ERC721
            interfaceId == 0x5b5e139f ||    // ERC165 Interface ID for ERC721Metadata
            interfaceId == 0x7aa5391d ||    // ERC165 Interface ID for IERC721
            interfaceId == 0x49064906 ||    // ERC165 Interface ID for IERC4906
            interfaceId == 0x01ffc9a7;      // ERC165 Interface ID for IERC165
	}
    
    function totalSupply() public view returns (uint256) { return _totalSupply; }
    
    function balanceOf(address executor) public view override returns (uint256) { return _balances[executor]; }

}

// File: DestinyTempleV7/core/IDestinyReserve.sol
pragma solidity 0.8.20;

/**
 *  @title -[天命联合储备]多签钱包合约.
 *
 *	@notice -使用链下[person_sign]签名交易,使用[ecrecover]验证签名.
 *
 *  @dev -也可使用[eth_sign]签署[keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", txHash));]哈希以生成与[person_sign]一致的签名.
 */
contract IDestinyReserve is IDestinyExecutor{
    event Reserved(address sender, uint256 amount, uint256 balance);
    event TransactionExecuted(bytes32 txHash);

    using BytesLib for bytes;
    using Strings for uint256;
    using Strings for bytes;

    struct Call {
        address target;
        uint256 value;
        bool allowFailure;
        bytes callData;
    }

    struct Result {
        bool success;
        bytes returnData;
    }

    uint256 private nonce;
    
    /**
	 *	@notice -若[signatures]合法且合约未被禁用,执行[calls]交易.
     *
     *  @dev [允许任何人调用] -若[calls]不允许失败时执行失败将回滚交易并尝试以[string]格式解码失败原因;
     *  @param calls -Call结构体数组,输入格式-[Call(address target,uint256 value,bool allowFailure,bytes callData),......].
     *  @param signatures -排序后的对[calls]的签名集合.
     *  @return results -返回执行状态和回执数据.
	 */
    function $ExecuteTx_JncUSiMDk5(
        Call[] calldata calls,
        bytes calldata signatures
    ) 
        external
        payable 
        returns (Result[] memory results)
    {
        //-如果合约被禁用则回滚.
        if(block.timestamp < enableTime) revert("Disabled");
        //-编码交易
        bytes32 txHash = $EncodeTxData(calls,nonce,block.chainid);
        //-首先自增nonce以防止重入.
        unchecked { ++nonce; }
        //-检查签名
        $CheckSignatures(txHash, signatures);

        uint256 length = calls.length;
        results = new Result[](length);
        //-循环以依次使用calls[i].calldata对calls[i].target进行调用并发送calls[i].value wei.
        for (uint256 i; i < length;) {
            Call calldata calli = calls[i];
            Result memory resulti = results[i];
            //-如果包含[铸造][命运神殿令牌]的调用则回滚.mint(address,uint256)" selector = 0x40c10f19
            if (bytes4(calli.callData) == 0x40c10f19) { if(calli.target == GovernanceToken) revert("Ban DST Mint Transaction."); }
            
            (resulti.success, resulti.returnData) = calli.target.call{value: calli.value}(calli.callData);
            //-当calli调用不允许失败并且调用失败时,回滚并拼接失败的calli下标至回滚消息..
            if (!(calli.allowFailure || resulti.success)){
                string memory revertMsg = string(abi.encodePacked("Revert Calls[",i.toString(),"]"));
                //-如果失败的调用有返回回滚提示,则拼接到回滚消息.
                if (resulti.returnData.length > 4){
                    revertMsg = string(abi.encodePacked(revertMsg,"  Reason:",abi.decode(resulti.returnData.slice(4,resulti.returnData.length - 4),(string))));
                }
                //-回滚并提示回滚消息.
                revert(revertMsg);
            }
            unchecked { ++i; }
        }
        emit TransactionExecuted(txHash);
    }

    function $Nonce() external view returns (uint256) { return nonce; }

    function $ChainId() external view returns (uint256) { return block.chainid; }

    function $TimeStamp() external view returns (uint256) { return block.timestamp; }

    /**
	 *	@notice -依据[signaturePacked]的签名地址对其和其签名地址从小到大排序.
     *
     *  @dev [允许任何人调用]
     *  @param txHash -通过[$EncodeTxData()]编码的交易哈希.
     *  @param signaturePacked -对[txHash]的签名集合.
     *  @return signaturesSorted -返回排序后的[签名]集合.
     *  @return signers -返回排序后的[签名者地址]集合.
	 */
    function $SortSignatures
    (
        bytes32 txHash,
        bytes memory signaturePacked
    )
        external 
        view 
        returns(bytes memory signaturesSorted,address[] memory signers)
    {
        uint256 _threshold = threshold;
        address signer;
        uint8 v;
        bytes32 r;
        bytes32 s;
        bytes[] memory signatures = new bytes[](_threshold);
        signers = new address[](_threshold);

        for (uint256 i = 0; i < _threshold;) {
            (v, r, s) = signatureSplit(signaturePacked, i);
            signatures[i] = abi.encodePacked(r,s,v);
            signer = ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", txHash)), v, r, s);
            signers[i] = signer;

            unchecked { ++i; }
        }

        for (uint i = 1;i < signers.length;){
            address temp = signers[i];
            bytes memory _temp = signatures[i];
            uint j=i;

            while( (j >= 1) && (temp < signers[j-1])){
                signatures[j] = signatures[j-1];
                signers[j] =signers[j-1];
                j--;
            }
            signatures[j] = _temp;
            signers[j] =temp;

            unchecked { ++i; }
        }

        for(uint i = 0;i<signatures.length;){
            signaturesSorted = abi.encodePacked(signaturesSorted,signatures[i]);
            unchecked { ++i; }
        }

        return(signaturesSorted,signers);
    }

    /**
	 *	@notice -以[_nonce]和[chainid]编码[calls]交易.
     *
     *  @dev [允许任何人调用]
     *  @param calls -调用结构体数组,输入格式-[Call(address target,uint256 value,bool allowFailure,bytes callData),......].
     *  @param _nonce -目标随机数.
     *  @param chainid -目标链编号.
     *  @return txHash -返回交易哈希.
	 */
    function $EncodeTxData(
        Call[] calldata calls,
        uint256 _nonce,
        uint256 chainid
    ) 
        public
        pure
        returns (bytes32 txHash) 
    {
        txHash = bytes32(
            abi.encodePacked(
                bytes1(0x77),
                bytes30(
                    keccak256(
                        abi.encode(
                            "$>>>Destiny Signed: destinytemple.eth<<<$",
                            calls,
                            _nonce,
                            chainid
                        )
                    )
                ),
                bytes1(0xde)
            )
        );
    }

    /**
	 *	@notice -使用[signatureSplit(bytes,uint256)]分割[signatures]并逐一检查其对于[txHash]的合法性.
     *
     *  @dev [允许任何人调用]
     *  @param txHash -通过[$EncodeTxData()]编码的交易哈希.
        @param signatures -排序后的对[txHash]的签名集合.
	 */
    function $CheckSignatures
    (
        bytes32 txHash,
        bytes memory signatures
    ) 
        public
        view 
    {
        uint256 _threshold = threshold;
        /*
         *-以太坊签名长度为65.
         *-如果输入签名集合长度小于[阈值]*65则回滚.
         */
        unchecked{ if(signatures.length < _threshold * 65) revert("NotEnoughSignatures"); }

        address lastExecutor = address(0); 
        address currentExecutor;
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint256 i;
        for (;i < _threshold;) {
            //-分割签名集合以得到单个签名的v,r,s并使用ecrecover恢复签名者地址.
            (v, r, s) = signatureSplit(signatures, i);
            currentExecutor = ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", txHash)), v, r, s);
            //-如果签名者不是执行者,回滚并提示签名者下标和其签名.
            if(balanceOf(currentExecutor) != 1) revert(string(abi.encodePacked("Invalid Signatures[",i.toString(),"]: Non-executor or not for this transaction: ",signatures.slice(i*65,65).toHexString())));
            //-如果签名者地址值小于等于上一个签名者,回滚并提示签名者下标和其签名.
            //-这样做是为了防止重复签名
            if(currentExecutor <= lastExecutor) revert(string(abi.encodePacked("invalid Signatures[",i.toString(),"]: Duplicate or unsorted: ",signatures.slice(i*65,65).toHexString())));
            lastExecutor = currentExecutor;
            unchecked { ++i; }
        }
    }

    /**
	 *	@notice -分割[signatures]中的第[pos]个[signature],返回v,r,s值.
     *
     *  @dev [仅内部调用]
     *  @param signatures -签名集合.
     *  @param pos -索引.
	 */
    function signatureSplit(bytes memory signatures, uint256 pos)
        internal
        pure
        returns (
            uint8 v,
            bytes32 r,
            bytes32 s
        )
    {
        assembly {
            let signaturePos := mul(0x41, pos)
            r := mload(add(signatures, add(signaturePos, 0x20)))
            s := mload(add(signatures, add(signaturePos, 0x40)))
            v := and(mload(add(signatures, add(signaturePos, 0x41))), 0xff)
        }
    }
}

// File: DestinyTempleV7/core/DestinyTemple.sol
pragma solidity 0.8.20;

/**         
 *  @title -[天命神殿]V7最终合约.
 *
 *  @notice -最终合同整合了上述所有内容.
 *
 *  @dev -合约可接受ETH和ERC20、ERC721、ERC1155等令牌储备.
 */
contract DestinyTempleV7 is IERC721Receiver,IERC1155Receiver,ITweet,IDestinyDeployer,IDestinyReserve{

    fallback() external payable { emit Reserved(msg.sender, msg.value, address(this).balance); }

    receive() external payable { emit Reserved(msg.sender, msg.value, address(this).balance); }

    /**
     *  @notice -用于接收ERC721令牌安全转账.
     *
     *  @dev -见[IERC721Receiver].
     */
	function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external pure override returns (bytes4){
		return IERC721Receiver.onERC721Received.selector;
	}

    /**
     *  @notice -用于接收ERC1155令牌安全转账.
     *
     *  @dev -见[IERC1155Receiver].
     */
	function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external pure override returns (bytes4){
		return IERC1155Receiver.onERC1155Received.selector;
	}

    /**
     *  @notice -用于接收ERC1155令牌批量安全转账.
     *
     *  @dev -见[IERC1155Receiver].
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external pure override returns (bytes4){
		return IERC1155Receiver.onERC1155BatchReceived.selector;
	}
}

/**
 * POSTSCRIPT:
 * 他们说从小缺爱的人,内心是没有力量的,心是空的,什么搞钱搞事业买房买车出人头地结婚生子之内的他的心对这些完全没有感觉,有感觉的时候就是焦虑,难受,恐惧,无助,空虚.
 * 可我不但缺爱我更缺钱,我觉得没有被爱是真的没有爱人的能力.我想要钱,可又好像没那么真想要,够活着就行了,现在也不怎么想活了,我从小缺乏安全感,这是寄宿学校和对父母的情感隔离带来的,我总是不安,后来,我想要钱来给我提供安全感,
 * 当我没钱时我会更加抑郁,我早就一无所有,连一点钱也没有了.
 *
 * 他们说心成长是需要爱的,如果只把孩子的身体养大,但是无法给孩子提供情绪价值,滋养内心,那这个孩子只是身体长大了,心里完全没有力量的,这样长大的人大部分在梦游,只能打份工养活自己,
 * 其他时间就不知道要干嘛,只能靠刷手机打发时间,完全没有自我成长的意识,因为心没感觉,
 * 唯一的动力是来自身体的欲望,性欲,物欲,食欲,但是欲望的力量是不长久的,所以不管做什么都是半途而废.
 *
 * 可是这一切都晚了,即使重来一遍,还是一样的轨迹,我终究无法逃出生来被定义的命运,,自己在中国什么阶层没点逼数吗能不能别生啊真恶心我恨你们.
 *
 * 我没有爱,我要钱,很多钱,没钱来改变的话,我最终应该是会自杀的,我总是能在一开始就看到结局.
 *
 * 我累了,随便写到这吧,以后发tweet,2023年7月25日凌晨3点42分.
 */

/** 
 * IMPRINT: 故事之外的故事.
 *
 * -林夕晨 （一） 
 * 
 * 注：此番外内容和小说剧情没有太大关系，仅仅只是写一些凌驾于虚幻之上的现实故事而已。 
 * 比如在和现实世界里的那些小说中的角色见面时所发生的一些故事。 
 * 其实也可以算是一个资料记录集。 
 * 就像分卷名写着的那样，这些，全都是在「故事之外的故事」。 
 *
 * 林夕晨是我写的故事里的一个重要角色，她的名字当然不叫林夕晨，所有角色的名字基本都不是真名，顶多就是那些角色们各自使用的女名而已。 
 * 林夕晨的女名也不叫林夕晨，说出来大家也不会熟悉，所以暂时就还是用书中的这个名字就好。 
 * 她的QQ昵称有很多，其中有一个知道的人并不多的就是叫夕子，大概用了一个星期的样子就换掉了吧，只是我也是在那一个时间段和她变得熟悉的，所以后来就用「夕子」来称呼她了。 
 * 在网络上我们大概认识了半年的时间吧，夕子在网络上从未动怒过，脾气好的惊人，有时候我也会口无遮拦地说一些不合时宜的话，但她却总是保持着足够的涵养和温柔。 
 * 而且很多时候不是强忍着怒火不发出来，而是由内到外的就没有因此而生气，我想，或许她的心真的是很温柔的吧。 
 * 其实她很少说话，见面时也多是在群里，聊天时都总是蹦几个字，话不多，但并不显得冷，这是一种很奇怪的感觉。 
 * 她是我的一个读者，早在我妻之前就已经进入了我的读者群了，但是我熟悉她的时候，却是写我妻已经到了中后期的时候了，因为她很少说话，自然就没有什么存在感嘛。 
 * 夕子在现实里也是一个药娘，不对，更准确的说，她应该是一个已经完成了手术的变性人，在身份证上的性别清清楚楚地写着‘女’这个字。 
 * 刚开始的时候我是将信将疑的，但是有不少我认识的药娘朋友都证实了一点，我也渐渐相信了。 
 * 在网络上对一个人的了解是有限的，再加上夕子特别的低调，在圈子里可以说几乎没有任何名气，除了少数几个人以外，认识她的，可能都寥寥无几。 
 * 大家都对她不算熟悉，或许我是她后来那一段时间里，最聊得来的朋友吧。   我从其他认识她的人那里，得到一些传闻，据说夕子被包养过，一直到现在都不知道是不是还在被包养着，而且她做的手术并不是最好的手术，而是比较勉强的那一种，或者说是最低价格，最低规格的手术吧。 
 * 手术是在国内的一个医院里进行的，但并不成功，这个是夕子自己告诉我的。   因为做的手术不太成功，所以在做完之后总会有各种各样的问题，比如说模具变形，开口处理不当导致肉重新长在一起——对于身体而言，那个被且开的口子，就像是伤口一样的，必须用各种方法来阻止愈合，才能形成一个稳定的不会变形的女**官。 
 * 那个时间大概要半年或者一年吧，夕子就是在这个不稳定的期间内，发生了很多问题。 
 * 发炎、流脓，之类的事情发生过许多次了，又因为手术的私密性，所以连伸张都不敢，只能私下里处理，这种事情真的很麻烦，钱花出去了，却无法把根源给看好。 
 * 有一段时间她说她甚至憋不住尿，反正也是手术的问题，好在后来这个问题被解决了，好像是使用材料的问题又或者是别的什么，反正我是记得不太清楚了。   很多人以为变性手术结束后就是美好生活的开始，可是夕子告诉了很多人，那可能是更痛苦的根源。 
 * 下身做手术的这段期间总是有各种问题，完全无法使用，甚至清理不干净还会有臭味——制作yin道的是小肠，优点是润滑，缺点是会长毛和发臭。 
 * 有些人使用的是YingJing皮，那个倒是不会发臭，但是不会自动分泌液体来润滑。   总之是各有优点吧，当然夕子不用后者来制作，是因为早早地去势后，失去了那两个器官，导致此处的皮萎缩了，长度不够……   具体的细节也不是很了解，这些仅仅只是从只言片语中整理出来的而已。 
 * 说起来，夕子诉苦的感觉也是很微妙的，不像别人那样打开了话匣子大倒苦水，而且总是表现的情绪很激烈。 
 * 虽然只是文字的聊天，但总能感受到她的温和，即使是这些头疼苦恼，让人发狂的事情，她也能乐观的去承受，也从来不会把悲惨的事情转变为怒火迁怒到其他人，更不会去自残。 
 * 反正我是从来没有听她说过什么要自残的话。 
 * 在那一段较为活跃的时间，夕子是几乎没有什么收入来源的，她的收入基本的依靠做淘宝客服得来，收入相当的低。 
 * 原来包养她的人，也随着她的手术带来的后遗症迟迟没有处理完而失去了耐心，将她甩开了。 
 * 原本被包养的时候，夕子一个月大概能拿到五千到一万不等的「零花钱」，而后来那一段时间，只能依靠当淘宝客服那微薄的工资来生活，到底有多少呢？   大概也就是1500块钱左右吧，可以说是少的可怜，但没办法，这已经是最适合她的工作了。 
 * 想想那一段时间，即使她还有存款，但是一边要生活，一边还要看病，解决手术的后遗症，就能知道，她过的到底是有多么辛苦了。 
 * 和夕子见面，其实是很偶然的一次，她来到了我所在的城市——准确的说应该是路过。 
 * 或许是在一个地方憋久了想四处走走，又或者从哪里拿到了一笔包养她的钱，总之她坐火车去四处旅行，范围不大，就是在沿海这一带的城市之间而已。 
 * 哦对了，题外话，关于包养的这件事情，可怜固然是可怜，但有时候也感觉这是自找的，明明她在大学毕业之后可以找一份工作的，但为了尽快筹集手术的钱就去找人包养她，当包养的习惯了，钱在不用工作的情况下获得的时间久了以后，一个人就几乎失去了工作能力了，这大概才是夕子找不好工作的原因吧，因为她可能……什么都不会。 
 * 或许‘什么都不会’，有些太绝对了，但大致就是这个意思。 
 * 那次她路过我所在的城市，要看一看这边的有名的景区，就问我，要不要见面。 
 * 既然来了，那我也自然不会推脱，当了一次导游，只是出发的匆忙，衣服也没怎么挑选，就是随便穿了平时的便服，相当邋遢的就过去了。 
 * 其实在我们俩见面了以后，风景是什么并不是重要的事情了，重点都被放在了聊天上。 
 * 初次见面，和我想的有些意外，夕子她竟然和网络里一样温柔——仅从外表上来看的话。 
 * 她的胸部不像是小说里写的那么大，但也不算小了，目测应该都有 B+或者 C 的等级吧。 
 * 夕子说，这是隆出来的胸，也就是里面填满了硅胶的产物。 
 * 虽然知道那是假的，但看着那白皙柔嫩的**，还是很有吸引力的，最起码一旁路过的男人，哪怕是老大爷，都会朝她看上一眼。 
 * 她看起来就是个女人，几乎可以说是毫无破绽，但据她自己说，她的缺点就是她的身高稍微高了一些。 
 * 夕子的身高大概是173的样子，比我要高一点。 
 * 但是现代社会，高挑的女性越来越多，所以这个完全不算缺点，甚至可以算是优点，我倒是觉得，她的唯一破绽是盆骨还是不够宽。 
 * 大概正是因为夕子的这种残念，所以我在设定小说的时候，把她的身高设定在了160，这是她心目中最理想的身高了。 
 * 夕子的声音略有些沙哑，她并没有做很完善的声带手术，只是单纯的把喉结给切除了而已。 
 * 如果不用伪声的话，实际上还是男声，只是较为中性一点而已。 
 * 她说的话不多，有各方面的原因，最重要的一点是，喉结手术也做的不是很好……   简单的说，就是耐久度下降了，她说的话多了，就会喉咙疼，甚至变得嘶哑，更何况是用很伤喉咙的伪声来说话呢。 
 * 她见到我的时候还有些害羞，但还是搭住了我的肩膀，就像是好哥们那样的勾肩搭背的感觉吧，只是她做这个动作要收敛得多，也要显得温柔的多。 
 * 夕子扎着双马尾，不是假发，而是真发，摸起来的手感并不算很好，微微有一些粗糙，可能是营养不良的缘故吧。 
 * 她没有做整形手术，因为她的钱只够她做那些最必要的手术，而且用的药物全是国产的……   当然不是支持国产，还是那句话，没钱。 
 * 在药娘的群体里来说，她绝对是那种天赋党，不然也不会有人包养她了，一个月五千到一万的零花钱不多，可也不算少了，要知道那可是白养啊，而且那些钱只是零花钱。 
 * 除了那些外，还有什么食宿费、各种礼物，全都是不要钱的呢。 
 * 夕子也很直白地说，被包养的时候，出去撒撒娇，就有很大的几率买到自己想要的东西，只要那东西不是贵得离谱就行。 
 * 比如那个时候刚出来的苹果手机，苹果电脑，也都是夕子在撒娇后，包养她的人毫不犹豫地买下来的。 
 * 虽然她说的有些话，都很直白，甚至很阴暗，但因为她总是带着那种温柔的笑，所以并不让人觉得讨厌，反而会让人觉得她很真实。 
 *  
 * 林夕晨 （二） 
 * 
 * 午餐选在了一个西餐厅里。 
 * 当然不是景区附近，作为一个……抠……嗯……节俭的人，怎么可能做那么浪费的事情呢。 
 * 景区附近量少质量也不好，而且还贵。 
 * 所以选择的是在我家附近的一家西餐厅里，这里人少，安静，有一种优雅的气氛，最重要的……便宜实惠。 
 * 吃了什么早已记不清了，反正一共是两百块不到的样子，对于西餐厅而言，这个价格并不算高了，而且吃的东西还是蛮多的。 
 * 西餐厅里，我和夕子选的是二楼靠窗的位置，可以看到楼下熙熙攘攘的行人和来往的车辆。 
 * 夕子切牛排的时候很熟练也很优雅，显然是经常吃的，相比之下我就显得笨拙了，最后无奈之下直接用嘴啃，还好没什么人，不然肯定很多人会投来异样的目光。 
 * “你讨厌被包养的我吗。”夕子冷不丁地问。 
 * 我愣了愣，回答她说，每个人都有每个人的苦衷。 
 * 实际上并没有正面回答这个问题，但她聪明的没有选择继续追问。 
 * 对于这种事情，我不支持也不反对，毕竟我不是夕子，不在那种环境下，是不可能判断对方所做所为是正确还是错误的。 
 * 有时候，这么做可能真的是出于无奈吧，最起码夕子她说，是不喜欢被包养的。 
 * 钱可以和很多东西进行取舍，而最终得到的结果，往往是舍弃别的，选择那足够多的金钱。 
 * 这是这个世间最浅显的道理，在各方各面中都会体现出来。 
 * 夕子也算是半个宅，毕竟被包养的那些日子，基本不外出，全都是窝在家里玩着电脑，所以在现实中也是有着不少共同语言的。 
 * 在度过刚开始的尴尬时期，就变得熟络了起来，毕竟在网络的世界里，我们俩可算是熟人呢。 
 * 见网友是一件很微妙的事情，哪怕是之前再三告诫自己，都会因为对方的形象是否符合自己内心的想法而感到失望或者满意……   夕子虽然和我想象中的有些不太一样，但大体的感觉是差不多的。 
 * 聊天的具体内容不太记得了，反正没有什么有营养的东西，都是在聊些动漫罢了。 
 * 而接下来的事情再一次让我见到了她的温柔以及……软弱。 
 * 她说要去超市里买些东西，然后继续去旅行。 
 * 因为超市不远，所以我们选择了步行，一路走过去，夕子也正好可以感受一下不同城市的风土人情嘛，所以她也没有拒绝。 
 * “好累。”她把一只手搭在我的肩膀上，然后单靠一只脚站在地上，用我的身体来保持平衡，一边隔着鞋子揉着脚，一边说道。 
 * 我对于这样是否能够减缓脚部的酸麻深表怀疑，但她看起来好像觉得有所缓解了的样子。 
 * 或许是因为是在冬天，脱了鞋子会很冷，所以才这么做的吧。 
 * 在去的路上，偶遇了一条流浪的土狗，短毛土狗看起来不算脏，但也绝对不算干净，它是黄色和白色相间的，真要形容的话，应该说是有点像秋田犬。 
 * 实际上在农村里这种狗是很常见的。 
 * 她好像很喜欢小动物，即使这是一只流浪狗，在后者表示出友好，并且主动靠近的时候，她很开心地蹲下身子，侧着脑袋，缓缓地摸着土狗身上粗糙的毛发。   流浪狗对她产生了信任感，以至于夕子站起来了，它还是在后面锲而不舍地跟着。 
 * 夕子看它还跟着，就又蹲下身摸它，然后再站起来继续走，见它还跟着，就再一次抚摸它的身子……   如此循环反复，以至于原本并不长的路，走了半个多小时。 
 * 然后她在便利店里买了三根烤肠——我和她一人一根，而额外的那一根，则送给了那只流浪狗。 
 * 她的眼神在那一刻格外的温柔。 
 * 能让人感觉到她内在善良美好的品质。但就算是这样善良美好的人，在经历过社会的黑暗之后，也总会说出一些……   怎么说呢，应该说是一些很负能量的话吧。 
 * 但说的往往都是事实，让人无力反驳呢。 
 * 在超市里的时候，有一个熊孩子逃脱了父母的‘追捕’，绕着林夕晨转圈圈，拉扯着她的衣服，甚至把她的棉制裙子都给拉歪了。 
 * 但夕子一直都没有生气，甚至连一点恼火的感觉都没有，也没有觉得无奈，反而是有一些好奇，甚至有一些羡慕。 
 * 她带着微笑看着那个调皮的熊孩子在自己的身前窜来窜去，一直到他的父母来拉走了他，我们才离开。 
 * “我喜欢小孩子。”夕子她笑着对我说，然后那温柔中带着沙哑的嗓音变得有些失落，“可惜……我不能……”   现实里的夕子不像小说里那样，她是一个非自然的女性，自然也就无法生育。   我其实不太能理解这一点，因为我个人是很讨厌熊孩子的，大概是因为无法忍受那些低情商的家伙吧。 
 * 虽然他们的低情商是年龄的缘故……   可能这和我较真的性格也有关系。 
 * “没关系，以后也可以领养的嘛。”我安慰道。 
 * “嗯，是呀。”夕子脸上的笑容多了起来，“我以后，想要领养一个女孩子。” 
 * “嗯，那很好啊。”   夕子说这话的时候，除了向往外，还有迷茫和惆怅，或许她是在想，自己到底能不能有领养孩子的那一天吧。 
 * 要知道，领养一个孩子，是需要多重手续的，最基本的条件，就是有一个稳定的收入来源，那个收入来源的钱足够的多，就算达不到小康水平，也得要接近才行。 
 * 而夕子她自己，都还是依靠着包养的钱来生活的呢……   超市里的购物车必须得塞入一枚一元硬币才可以借走，这么做是为了让人们主动把购物车给放好——只有把购物车放回到指定地点，才可以把那一元硬币重新取出来。 
 * 刚进超市，也只是随便地逛逛，没有什么想买的，购物车自然也是空荡荡的。   看商品的时候，把购物车放在了一旁，然后往里面走了一点，去看商品，结果回过头来的时候，却发现我们自己的购物车被一个老头给拉走了。 
 * 这里的称呼比较粗俗，但对于这种为老不尊的老人，我觉得在前面加个‘死’ 字，或许才更符合我当时的心情。 
 * 我正想上前质问，但夕子却比我还快地走上了前，她很有礼貌的对那个死老头说：“您好……这辆购物车是我们的，您是不是推错了？” 
 * “怎么就是你的了，这是我自己从外面推进来的。” 
 * “可是，这辆车……真的是我们的……我们刚才就放在这里……车身的一个轮子是破的……我记得……” 
 * “什么破的不破的，现在的年轻人，难道连一块钱的便宜都想占吗！还要不要脸了，有没有素质啊！”   那个老头破口大骂，他后面还说了些什么，终归是一些不好听的话，我不太记得了。 
 * 只记得，夕子在当时表现的很委屈，甚至带着些哭腔说：“对、对不起……” 明明不是她的错，为什么要说对不起？   我上前大声地呵斥了这个老头一顿，对于这种为老不尊的人，只有表现的比他更强势，他才会害怕。 
 * 车子要了回来，但是好心情却被他给破坏干净了。 
 * 我回过头去看的时候，发现夕子正在流泪，两滴泪水从眼角里流了出来，眼眶里还有更多，只是她在强忍着。 
 * “怎么了？”看着她哭的样子，我有些心疼。 
 * 应该说，是个正常人都会觉得心疼吧。 
 * “没事……” 
 * “和那种人不值得生气。”我劝慰道。 
 * 但是从她的眼中看不到生气的情绪，有的只是委屈而已。 
 * 她好像真的不会生气一样，该说她的脾气太好，太温柔了，还是说她实在是太软弱了呢？   走到如今，和她的性格肯定脱不开关系。 
 * 晚上她没有离开这座城市，而是选择在这里过夜。 
 * 住的是我帮她安排的宾馆，不，说是旅馆可能更合适一些，因为我问过她，她说自己手里的钱也不是很多，所以尽量帮她找了一家便宜的地方。 
 * 住一个晚上只要七十块钱。 
 * 在这个大城市里，这个价格已经很低了。 
 * 当然，环境也好不到哪里去。 
 * 晚上的时候，她问我，能不能陪她一起睡……   她觉得寂寞，希望我能再陪她一会儿，因为明天她就要离开了。 
 * 车票是在吃午饭的时候就在网上买好了。 
 * 她那楚楚可怜的样子实在是让人不忍心拒绝，所以我在她的邀请下进入了她的被窝里。 
 * 当然了，虽然床很小，我也还是什么也没做，甚至连触碰她的身体的动作都尽量避免。 
 * 夕子的身上有一股淡淡的香味，像是兰花的香，她说这是香水的味道，是一种不算便宜的香水。 
 * 我陪她聊到了很晚，大概是晚上十二点左右吧，她的回应越来越轻，然后就在这月光的笼罩下睡着了。 
 * 我起身帮她拉上了窗帘，然后穿好衣服悄悄离开了，终究还是没有在这里陪她过夜。 
 * 第二天早上，她发消息问我去哪里了，我就装作是出去买早饭了——那个旅馆离我家很近，我可以很完美的伪装成昨天陪了她一整个晚上。 
 * 她没有察觉，或许是察觉了，但没有说出来吧。 
 * 在中午的时候，我在火车站里和她道别了。 
 * 之后的联系开始变得断断续续起来，或许是因为她正在旅行的缘故。 
 * 生活中总是有很多事情，我对于这种断断续续的联系并不在意。 
 * 但是有一天，我突然就联系不上她了，无论是 QQ 还是手机都无法联系到她，甚至包括她的那些好友，都和她失去了联系。 
 * 她就像是失踪了一样，在这个世界上消失了。 
 * 直到现在。 
 * 我都没有再联系到过她。 
 * 不知道她过的怎么样，甚至不知道她是否还活着。作为她的朋友，我偶尔还会想起她来，只是不知道随着时间的推移，会不会将她忘记，最起码，现在她在我脑海里的记忆已经很淡了。 
 * 一个心里装了美好和善良，温柔又软弱，很少去抱怨世界的不好的人……   虽然只是见了一次，但却给我留下了深刻的印象。 
 * 把她的故事简单的写在这里，或许也是为了在我以后的记忆更模糊的时候，能回过头看看，想起当初她的模样吧。 
 * 我很喜欢温柔的夕子，但我知道那不是爱情，充其量只是友情和同情的混合体吧。 
 * 嗯……说了很多。 
 * 总之，这就是夕子的故事了。 
 * 现实和小说总是有着很多的不同的，小说来源于现实，也高于现实，却永远不可能像现实那样绝对的真实。 
 * 这就是在，故事之外的……故事。 
 *
 * -《药娘的天空》后记 节选.
 *
 */
/*=======================================================================================================================
#            __                                 __                               __                                     #
#           /  \ |  o     _  ._ _  o     _.    /  \  _  _  | _|_  _ |  _.       /  \    o _  o                          #
#          | (|/ |< | \/ (_) | | | | \/ (_|   | (|/ _> (_) |  |_ (_ | (_| \/   | (|/ >< | /_ |                          #
#           \__       /              /         \__                        /     \__                                     #
#            __                                  __                                    __                               #
#           /  \  _             _. o ._   _     /  \  _|                    _. ._     /  \  _ o  _  _.  _|  _.          #
#          | (|/ _> |_| \/ |_| (_| | | | (_|   | (|/ (_| |_| \/ |_| >< |_| (_| | |   | (|/ (_ | (_ (_| (_| (_|          #
#           \__         /        |        _|    \__          /                        \__                               #
#            __                             __                    __              __                                    #
#           /  \ o o  _. ._          _     /  \     ._ _   _     /  \     | o    /  \ |_   _. ._    |   _.              #
#          | (|/ | | (_| | | \/ |_| (/_   | (|/ |_| | | | (_)   | (|/ |_| | |   | (|/ | | (_| | |_| |< (_|              #
#           \__ _|           /             \__                   \__             \__                                    #
#                                                                                                                       #
/*======================================================================================================================*
#                                                                                                                       #
#     ██████╗ ███████╗███████╗████████╗██╗███╗   ██╗██╗   ██╗████████╗███████╗███╗   ███╗██████╗ ██╗     ███████╗       #
#     ██╔══██╗██╔════╝██╔════╝╚══██╔══╝██║████╗  ██║╚██╗ ██╔╝╚══██╔══╝██╔════╝████╗ ████║██╔══██╗██║     ██╔════╝       #
#     ██║  ██║█████╗  ███████╗   ██║   ██║██╔██╗ ██║ ╚████╔╝    ██║   █████╗  ██╔████╔██║██████╔╝██║     █████╗         #
#     ██║  ██║██╔══╝  ╚════██║   ██║   ██║██║╚██╗██║  ╚██╔╝     ██║   ██╔══╝  ██║╚██╔╝██║██╔═══╝ ██║     ██╔══╝         #
#     ██████╔╝███████╗███████║   ██║   ██║██║ ╚████║   ██║      ██║   ███████╗██║ ╚═╝ ██║██║     ███████╗███████╗       #
#     ╚═════╝ ╚══════╝╚══════╝   ╚═╝   ╚═╝╚═╝  ╚═══╝   ╚═╝      ╚═╝   ╚══════╝╚═╝     ╚═╝╚═╝     ╚══════╝╚══════╝       #
#                                                                                                                       #
*=======================================================================================================================*
#                                                           ..                                                          #
#                                                           ::                                                          #
#                                                           !!                                                          #
#                                                          .77.                                                         #
#                                                          ~77~                                                         #
#                                                         .7777.                                                        #
#                                                         !7777!                                                        #
#                                                        ^777777^                                                       #
#                                                       ^77777777^                                                      #
#                                                      ^777!~~!777^                                                     #
#                                                     ^7777!::!7777^                                                    #
#                                                   .~77777!  !77777~.                                                  #
#                                                  :!77777!:  :!77777!:                                                 #
#                                                 ~777777!^    ^!777777~                                                #
#                                               :!7777777^      ^7777777!:                                              #
#                                             :!77777777:        :77777777!:                                            #
#                                           :!77777777!.          .!77777777!:                                          #
#                                        .^!77777777!^              ^!77777777!^.                                       #
#                                      :~7777777777^.       ..       .^7777777777~:                                     #
#                                   .^!777777777!^.         ^^         .^!777777777!^.                                  #
#                               .:~!777777777!~:           :77:           :~!777777777!~:.                              #
#                           .:^!7777777777!~:             ^7777^             :~!7777777777!^:.                          #
#                     ..:^~!77777777!!~^:.             .^!777777!^.             .:^~!!77777777!~^:..                    #
#           ...::^^~!!77777777~~^^:..              .:^!777777777777!^:.              ..:^^~~77777777!!~^^::...          #
#           ...::^^~!!77777777~~^^:..              .:^!777777777777!^:.              ..:^^~~77777777!!~^^::...          #
#                     ..:^~!77777777!!~^:.             .^!777777!^.             .:^~!!77777777!~^:..                    #
#                           .:^!7777777777!~:             ^7777^             :~!7777777777!^:.                          #
#                               .:~!777777777!~:           :77:           :~!777777777!~:.                              #
#                                   .^!777777777!^.         ^^         .^!777777777!^.                                  #
#                                      :~7777777777^.       ..       .^7777777777~:                                     #
#                                        .^!77777777!^              ^!77777777!^.                                       #
#                                           :!77777777!.          .!77777777!:                                          #
#                                             :!77777777:        :77777777!:                                            #
#                                               :!7777777^      ^7777777!:                                              #
#                                                 ~777777!^    ^!777777~                                                #
#                                                  :!77777!:  :!77777!:                                                 #
#                                                   .~77777!  !77777~.                                                  #
#                                                     ^7777!::!7777^                                                    #
#                                                      ^777!~~!777^                                                     #
#                                                       ^77777777^                                                      #
#                                                        ^777777^                                                       #
#                                                         !7777!                                                        #
#                                                         .7777.                                                        #
#                                                          ~77~                                                         #
#                                                          .77.                                                         #
#                                                           !!                                                          #
#                                                           ::                                                          #
#                                                           ..                                                          #
#                                                       天命与你同在.                                                    #
========================================================================================================================*/