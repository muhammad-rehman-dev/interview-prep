# frozen_string_literal: true

module Content
  class CheatsheetGenerator
    def self.blueprints
      entries.each_with_index.map { |e, i| e.merge(position: i + 1) }
    end

    def self.entries
      [
        {
          title: "ActiveRecord Models",
          slug: "activerecord-models",
          rails_concept: "ActiveRecord::Base models map tables to Ruby objects with persistence APIs.",
          rails_explanation: "Models inherit from ApplicationRecord, define validations, associations, and scopes. Query with where/find, persist with save/update/destroy.",
          node_equivalent: "Plain classes + a query layer (knex/pg/Prisma client) without opinionated ActiveRecord magic.",
          nest_equivalent: "TypeORM/Prisma entities + injectable repositories/services in Nest providers.",
          rails_code: "class User < ApplicationRecord\n  validates :email, presence: true, uniqueness: true\n  has_many :posts\nend\n\nUser.create!(email: \"a@b.com\")\nUser.find_by(email: \"a@b.com\")",
          node_code: "const user = await prisma.user.create({ data: { email } });\nconst found = await prisma.user.findUnique({ where: { email } });",
          nest_code: "@Entity() export class User {\n  @PrimaryGeneratedColumn('uuid') id: string;\n  @Column({ unique: true }) email: string;\n  @OneToMany(() => Post, p => p.user) posts: Post[];\n}\n\n@Injectable() export class UsersService {\n  constructor(@InjectRepository(User) private repo: Repository<User>) {}\n  create(dto) { return this.repo.save(this.repo.create(dto)); }\n}",
          category: "ORM"
        },
        {
          title: "ActiveRecord Callbacks",
          slug: "activerecord-callbacks",
          rails_concept: "before_validation / before_save / after_commit hooks on model lifecycle.",
          rails_explanation: "Callbacks run around persistence. Prefer after_commit for side effects (email, jobs) so they don't run on rolled-back transactions.",
          node_equivalent: "Manual hooks in service layer, or ORM middleware (Prisma $use, Mongoose pre/post).",
          nest_equivalent: "Entity subscribers (TypeORM), Prisma middleware, or explicit service orchestration.",
          rails_code: "before_validation :normalize_email\nafter_commit :enqueue_welcome_email, on: :create\n\ndef normalize_email\n  self.email = email.to_s.downcase.strip\nend",
          node_code: "prisma.$use(async (params, next) => {\n  if (params.model === 'User' && params.action === 'create') {\n    params.args.data.email = params.args.data.email.toLowerCase();\n  }\n  return next(params);\n});",
          nest_code: "@EventSubscriber() export class UserSubscriber implements EntitySubscriberInterface<User> {\n  listenTo() { return User; }\n  beforeInsert(event: InsertEvent<User>) {\n    event.entity.email = event.entity.email.toLowerCase();\n  }\n  async afterInsert(event: InsertEvent<User>) {\n    await this.queue.add('welcome', { userId: event.entity.id });\n  }\n}",
          category: "ORM"
        },
        {
          title: "before_action Filters",
          slug: "before-action-filters",
          rails_concept: "Controller callbacks that run before actions (auth, load resource, set locale).",
          rails_explanation: "before_action :authenticate_user!, :set_post. Use only/except to scope. Skips with skip_before_action.",
          node_equivalent: "Express middleware mounted per-router or per-route.",
          nest_equivalent: "Guards (CanActivate), middleware, and interceptors for cross-cutting concerns.",
          rails_code: "class PostsController < ApplicationController\n  before_action :authenticate_user!\n  before_action :set_post, only: %%i[show update destroy]\n\n  private\n  def set_post\n    @post = Post.find(params[:id])\n  end\nend",
          node_code: "router.use(authMiddleware);\nrouter.get('/:id', loadPost, (req, res) => res.json(req.post));",
          nest_code: "@UseGuards(JwtAuthGuard)\n@Controller('posts') export class PostsController {\n  @Get(':id') find(@Param('id') id: string) { return this.posts.findOne(id); }\n}\n\n@Injectable() export class JwtAuthGuard implements CanActivate {\n  canActivate(ctx: ExecutionContext) { /* validate JWT */ return true; }\n}",
          category: "Controllers"
        },
        {
          title: "Strong Parameters",
          slug: "strong-parameters",
          rails_concept: "Explicit permit/require on params to prevent mass assignment.",
          rails_explanation: "params.require(:user).permit(:email, :name). Nested attributes need special permit shapes.",
          node_equivalent: "Manual pick/omit or schema validation (Joi/Zod) before passing to DB.",
          nest_equivalent: "DTO classes with class-validator + ValidationPipe whitelist/forbidNonWhitelisted.",
          rails_code: "def user_params\n  params.require(:user).permit(:email, :name, address: %%i[city zip])\nend",
          node_code: "const body = userSchema.parse(req.body); // zod\nconst { email, name } = body;",
          nest_code: "export class CreateUserDto {\n  @IsEmail() email: string;\n  @IsString() @MinLength(2) name: string;\n}\n// main.ts: new ValidationPipe({ whitelist: true, forbidNonWhitelisted: true })",
          category: "Controllers"
        },
        {
          title: "Routes and Resources",
          slug: "routes-and-resources",
          rails_concept: "config/routes.rb maps HTTP verbs/paths to controller#action; resources generate REST routes.",
          rails_explanation: "resources :posts; namespace :api do ... end; member/collection routes for custom actions.",
          node_equivalent: "Express Router with app.use('/posts', postsRouter).",
          nest_equivalent: "@Controller('posts') methods with @Get/@Post/@Patch/@Delete; modules import controllers.",
          rails_code: "Rails.application.routes.draw do\n  namespace :api do\n    resources :posts do\n      member { post :publish }\n    end\n  end\nend",
          node_code: "const r = express.Router();\nr.get('/', list); r.post('/', create);\nr.post('/:id/publish', publish);\napp.use('/api/posts', r);",
          nest_code: "@Controller('api/posts') export class PostsController {\n  @Get() list() {}\n  @Post() create(@Body() dto: CreatePostDto) {}\n  @Post(':id/publish') publish(@Param('id') id: string) {}\n}",
          category: "Routing"
        },
        {
          title: "Controllers",
          slug: "controllers",
          rails_concept: "Thin HTTP adapters that parse params, call models/services, render responses.",
          rails_explanation: "Actions should stay thin; push business logic to models or service objects. Use rescue_from for errors.",
          node_equivalent: "Route handlers calling services; keep handlers free of business rules.",
          nest_equivalent: "Controllers inject services; return plain objects (serialized by Nest interceptors).",
          rails_code: "def create\n  post = Posts::Create.call(post_params)\n  render json: post, status: :created\nend",
          node_code: "async function create(req, res) {\n  const post = await postsService.create(req.body);\n  res.status(201).json(post);\n}",
          nest_code: "@Controller('posts') export class PostsController {\n  constructor(private posts: PostsService) {}\n  @Post() @HttpCode(201) create(@Body() dto: CreatePostDto) {\n    return this.posts.create(dto);\n  }\n}",
          category: "Controllers"
        },
        {
          title: "Models vs Domain Objects",
          slug: "models-vs-domain",
          rails_concept: "Fat models vs extracting POROs/service objects for complex workflows.",
          rails_explanation: "Keep AR for persistence/invariants; move multi-model workflows to services to avoid god models.",
          node_equivalent: "Separate domain services from data-access modules.",
          nest_equivalent: "Providers/services + repositories; domain modules with clear boundaries.",
          rails_code: "class Orders::Checkout\n  def self.call(user:, cart:)\n    Order.transaction { /* create order, decrement inventory */ }\n  end\nend",
          node_code: "export async function checkout({ userId, cartId }, { db, tx }) {\n  return tx(async (client) => { /* ... */ });\n}",
          nest_code: "@Injectable() export class CheckoutService {\n  constructor(private dataSource: DataSource) {}\n  checkout(dto: CheckoutDto) {\n    return this.dataSource.transaction(async (m) => { /* ... */ });\n  }\n}",
          category: "Architecture"
        },
        {
          title: "Serializers / Blueprints",
          slug: "serializers-blueprints",
          rails_concept: "Shape JSON responses via ActiveModel::Serializer, Alba, or Blueprinter.",
          rails_explanation: "Decouple DB shape from API contract; include associations explicitly; version serializers.",
          node_equivalent: "Manual mappers or class-transformer-style presenters.",
          nest_equivalent: "class-transformer @Exclude/@Expose, interceptor serialization, or dedicated presenter services.",
          rails_code: "class PostSerializer < Blueprinter::Base\n  identifier :id\n  fields :title, :body\n  association :author, blueprint: UserSerializer\nend",
          node_code: "function serializePost(p) {\n  return { id: p.id, title: p.title, author: { id: p.author.id, name: p.author.name } };\n}",
          nest_code: "export class PostEntity {\n  @Expose() id: string;\n  @Expose() title: string;\n  @Exclude() internalScore: number;\n}\n// ClassSerializerInterceptor + @Exclude on sensitive fields",
          category: "APIs"
        },
        {
          title: "Background Jobs (ActiveJob)",
          slug: "background-jobs-activejob",
          rails_concept: "ActiveJob adapters (Sidekiq/GoodJob) for async work with retries.",
          rails_explanation: "ApplicationJob subclasses perform work later. Use after_commit to enqueue. Configure queues and retry/discard.",
          node_equivalent: "Bull/BullMQ, Agenda, or cloud queues (SQS) with worker processes.",
          nest_equivalent: "@nestjs/bullmq processors + Queue producers injected into services.",
          rails_code: "class WelcomeEmailJob < ApplicationJob\n  queue_as :mailers\n  def perform(user_id)\n    UserMailer.welcome(User.find(user_id)).deliver_now\n  end\nend\nWelcomeEmailJob.perform_later(user.id)",
          node_code: "await welcomeQueue.add('welcome', { userId }, { attempts: 5, backoff: { type: 'exponential', delay: 1000 } });",
          nest_code: "@Injectable() export class MailProducer {\n  constructor(@InjectQueue('mail') private q: Queue) {}\n  enqueueWelcome(userId: string) { return this.q.add('welcome', { userId }); }\n}\n@Processor('mail') export class MailProcessor {\n  @Process('welcome') async handle(job: Job<{ userId: string }>) { /* send */ }\n}",
          category: "Jobs"
        },
        {
          title: "ActionCable WebSockets",
          slug: "actioncable-websockets",
          rails_concept: "ActionCable channels for pub/sub over WebSockets.",
          rails_explanation: "Channel classes stream_from streams; client subscribe. Auth in Connection. Use Redis adapter in multi-process.",
          node_equivalent: "ws / Socket.IO rooms with Redis adapter.",
          nest_equivalent: "@WebSocketGateway gateways with rooms and Redis IoAdapter.",
          rails_code: "class ChatChannel < ApplicationCable::Channel\n  def subscribed\n    stream_from \"chat_\#{params[:room_id]}\"\n  end\n  def speak(data)\n    ActionCable.server.broadcast(\"chat_\#{params[:room_id]}\", data)\n  end\nend",
          node_code: "io.on('connection', (socket) => {\n  socket.join(roomId);\n  socket.on('speak', (msg) => io.to(roomId).emit('message', msg));\n});",
          nest_code: "@WebSocketGateway({ namespace: '/chat' }) export class ChatGateway {\n  @SubscribeMessage('join') handleJoin(client: Socket, roomId: string) { client.join(roomId); }\n  @SubscribeMessage('speak') handleSpeak(client: Socket, payload: { roomId: string; text: string }) {\n    client.to(payload.roomId).emit('message', payload);\n  }\n}",
          category: "Realtime"
        },
        {
          title: "Service Objects",
          slug: "service-objects",
          rails_concept: "Single-purpose POROs encapsulating a use case (call/perform pattern).",
          rails_explanation: "Input -> validate -> transaction -> result object. Improves testability vs fat controllers/models.",
          node_equivalent: "Use-case functions/classes in a services/ folder.",
          nest_equivalent: "Injectable services with one public method per use case; command pattern optional.",
          rails_code: "class Users::Register\n  Result = Struct.new(:ok?, :user, :errors, keyword_init: true)\n  def self.call(email:, password:)\n    user = User.new(email:, password:)\n    user.save ? Result.new(ok?: true, user:) : Result.new(ok?: false, errors: user.errors)\n  end\nend",
          node_code: "export async function registerUser({ email, password }, deps) {\n  const hash = await deps.hash(password);\n  return deps.users.create({ email, passwordHash: hash });\n}",
          nest_code: "@Injectable() export class RegisterUserService {\n  constructor(private users: UsersService, private hasher: PasswordService) {}\n  async execute(dto: RegisterDto) {\n    const passwordHash = await this.hasher.hash(dto.password);\n    return this.users.create({ email: dto.email, passwordHash });\n  }\n}",
          category: "Architecture"
        },
        {
          title: "POROs",
          slug: "poros",
          rails_concept: "Plain Old Ruby Objects — non-AR classes for domain logic, value objects, form objects.",
          rails_explanation: "Use for calculations, policies, form objects including ActiveModel::Model without a table.",
          node_equivalent: "Plain TypeScript classes/functions; value objects as frozen data.",
          nest_equivalent: "Plain TS classes not registered as providers when pure; providers when needing DI.",
          rails_code: "class Money\n  def initialize(cents) = @cents = cents\n  def +(other) = Money.new(@cents + other.cents)\n  attr_reader :cents\nend",
          node_code: "export class Money {\n  constructor(public readonly cents: number) {}\n  add(other: Money) { return new Money(this.cents + other.cents); }\n}",
          nest_code: "// Pure domain — no @Injectable needed\nexport class Money {\n  constructor(public readonly cents: number) {}\n  add(other: Money) { return new Money(this.cents + other.cents); }\n}",
          category: "Architecture"
        },
        {
          title: "Concerns (ActiveSupport::Concern)",
          slug: "concerns",
          rails_concept: "Reusable modules mixed into models/controllers with included/class_methods.",
          rails_explanation: "Extract shared scopes, methods, callbacks. Overuse creates implicit dependency webs — prefer composition.",
          node_equivalent: "Shared utility modules or mixins (less idiomatic than composition).",
          nest_equivalent: "Shared providers, base classes sparingly, or helper modules imported explicitly.",
          rails_code: "module Publishable\n  extend ActiveSupport::Concern\n  included do\n    scope :published, -> { where.not(published_at: nil) }\n  end\n  def publish! = update!(published_at: Time.current)\nend",
          node_code: "export const publishedWhere = { publishedAt: { not: null } };\nexport async function publish(repo, id) {\n  return repo.update({ where: { id }, data: { publishedAt: new Date() } });\n}",
          nest_code: "@Injectable() export class PublishableService {\n  async publish(repo: Repository<any>, id: string) {\n    await repo.update(id, { publishedAt: new Date() });\n  }\n}",
          category: "Architecture"
        },
        {
          title: "Rack Middleware",
          slug: "rack-middleware",
          rails_concept: "Rack middleware wraps the app; each #call(env) can mutate request/response.",
          rails_explanation: "Rails is a Rack app. Insert middleware in config/application.rb for auth edge, request IDs, etc.",
          node_equivalent: "Express middleware (req, res, next).",
          nest_equivalent: "NestMiddleware implementing NestMiddleware, or global Express middleware via app.use.",
          rails_code: "class RequestIdMiddleware\n  def initialize(app) = @app = app\n  def call(env)\n    env['action_dispatch.request_id'] ||= SecureRandom.uuid\n    @app.call(env)\n  end\nend",
          node_code: "function requestId(req, res, next) {\n  req.id = req.headers['x-request-id'] || crypto.randomUUID();\n  res.setHeader('x-request-id', req.id);\n  next();\n}",
          nest_code: "@Injectable() export class RequestIdMiddleware implements NestMiddleware {\n  use(req: Request, res: Response, next: NextFunction) {\n    req['id'] = req.headers['x-request-id'] || randomUUID();\n    res.setHeader('x-request-id', req['id']);\n    next();\n  }\n}",
          category: "Middleware"
        },
        {
          title: "Sessions",
          slug: "sessions",
          rails_concept: "Encrypted/signed cookie session store (default) or Redis/store session.",
          rails_explanation: "session[:user_id] = id after login. CSRF protection for cookie sessions. Prefer short expiry + rotate.",
          node_equivalent: "express-session with Redis store, or JWT (stateless) instead of server sessions.",
          nest_equivalent: "cookie-session / express-session via middleware, or JWT passport strategy.",
          rails_code: "def create\n  user = User.authenticate(params[:email], params[:password])\n  reset_session\n  session[:user_id] = user.id\n  redirect_to root_path\nend",
          node_code: "req.session.regenerate(() => {\n  req.session.userId = user.id;\n  res.json({ ok: true });\n});",
          nest_code: "// Cookie session middleware in main.ts, then:\n@Post('login') login(@Req() req, @Body() dto: LoginDto) {\n  const user = await this.auth.validate(dto);\n  req.session.userId = user.id;\n  return { ok: true };\n}",
          category: "Auth"
        },
        {
          title: "Cookies",
          slug: "cookies",
          rails_concept: "cookies[] signed/encrypted cookie jars in Rails.",
          rails_explanation: "cookies.signed[:token] = value; cookies.encrypted for secrets. Set httponly, secure, same_site.",
          node_equivalent: "res.cookie / cookie-parser; manually sign if needed.",
          nest_equivalent: "@Res() cookie API or dedicated cookie module; prefer httpOnly for tokens.",
          rails_code: "cookies.signed[:remember] = { value: user.id, httponly: true, secure: Rails.env.production?, same_site: :lax }",
          node_code: "res.cookie('remember', token, { httpOnly: true, secure: true, sameSite: 'lax', maxAge: 604e5 });",
          nest_code: "@Post('logout') logout(@Res({ passthrough: true }) res: Response) {\n  res.clearCookie('remember', { httpOnly: true, secure: true, sameSite: 'lax' });\n  return { ok: true };\n}",
          category: "Auth"
        },
        {
          title: "Rails Caching",
          slug: "rails-caching",
          rails_concept: "Russian doll / fragment / low-level Rails.cache (Redis/Memcached).",
          rails_explanation: "Rails.cache.fetch(key, expires_in:) { compute }. Sweep or key on updated_at for invalidation.",
          node_equivalent: "ioredis get/set with TTL; cache-aside in services.",
          nest_equivalent: "CacheModule (cache-manager) with Redis store; interceptors for HTTP cache optional.",
          rails_code: "Rails.cache.fetch([\"user\", user.id, user.updated_at], expires_in: 10.minutes) do\n  UserSerializer.render(user)\nend",
          node_code: "const key = `user:${id}`;\nconst cached = await redis.get(key);\nif (cached) return JSON.parse(cached);\nconst user = await db.user.find(id);\nawait redis.set(key, JSON.stringify(user), 'EX', 600);\nreturn user;",
          nest_code: "@Injectable() export class UsersService {\n  constructor(@Inject(CACHE_MANAGER) private cache: Cache) {}\n  async findOne(id: string) {\n    return this.cache.wrap(`user:${id}`, () => this.repo.findOneByOrFail({ id }), 600_000);\n  }\n}",
          category: "Caching"
        },
        {
          title: "Transactions",
          slug: "transactions",
          rails_concept: "ActiveRecord::Base.transaction ensures atomic multi-statement changes.",
          rails_explanation: "Nested transactions use savepoints. after_commit for side effects. Lock with with_lock / lock!.",
          node_equivalent: "BEGIN/COMMIT via client or Prisma $transaction.",
          nest_equivalent: "DataSource.transaction / Prisma $transaction in services.",
          rails_code: "ActiveRecord::Base.transaction do\n  from.with_lock { from.update!(balance: from.balance - amount) }\n  to.with_lock { to.update!(balance: to.balance + amount) }\nend",
          node_code: "await prisma.$transaction(async (tx) => {\n  await tx.account.update({ where: { id: fromId }, data: { balance: { decrement: amount } } });\n  await tx.account.update({ where: { id: toId }, data: { balance: { increment: amount } } });\n});",
          nest_code: "await this.dataSource.transaction(async (manager) => {\n  const from = await manager.findOne(Account, { where: { id: fromId }, lock: { mode: 'pessimistic_write' } });\n  // debit/credit then save\n});",
          category: "ORM"
        },
        {
          title: "Validations",
          slug: "validations",
          rails_concept: "Model validations run on save; errors collection for invalid records.",
          rails_explanation: "validates presence/uniqueness/format; custom validate methods. Contexts with on: :create.",
          node_equivalent: "Schema validation at boundary (Zod) separate from DB constraints.",
          nest_equivalent: "DTO class-validator + DB constraints; pipes transform/validate before controller.",
          rails_code: "validates :email, presence: true, uniqueness: { case_sensitive: false }\nvalidate :password_complexity, if: :password_digest_changed?",
          node_code: "const schema = z.object({ email: z.string().email(), password: z.string().min(12) });",
          nest_code: "export class RegisterDto {\n  @IsEmail() email: string;\n  @MinLength(12) password: string;\n  @Matches(/[A-Z]/, { message: 'need uppercase' }) password!: string;\n}",
          category: "ORM"
        },
        {
          title: "Associations",
          slug: "associations",
          rails_concept: "has_many / belongs_to / has_one / has_and_belongs_to_many / has_many :through.",
          rails_explanation: "Declare inverse_of, dependent:, optional: for belongs_to. through models for join attributes.",
          node_equivalent: "Foreign keys + manual joins or Prisma relation fields.",
          nest_equivalent: "TypeORM @ManyToOne/@OneToMany/@ManyToMany or Prisma relation syntax.",
          rails_code: "belongs_to :author, class_name: 'User', inverse_of: :posts\nhas_many :comments, dependent: :destroy\nhas_many :tags, through: :taggings",
          node_code: "model Post {\n  author   User @relation(fields: [authorId], references: [id])\n  authorId String\n  tags     Tag[]\n}",
          nest_code: "@ManyToOne(() => User, u => u.posts) @JoinColumn() author: User;\n@OneToMany(() => Comment, c => c.post) comments: Comment[];\n@ManyToMany(() => Tag, t => t.posts) @JoinTable() tags: Tag[];",
          category: "ORM"
        },
        {
          title: "Migrations",
          slug: "migrations",
          rails_concept: "Versioned schema changes via bin/rails g migration; up/down or change.",
          rails_explanation: "Keep reversible; add indexes concurrently in Postgres with disable_ddl_transaction!; never edit old migrations in prod.",
          node_equivalent: "Knex migrations, node-pg-migrate, or Prisma migrate.",
          nest_equivalent: "TypeORM migrations or Prisma migrate deployed in CI/CD.",
          rails_code: "class AddIndexToUsersEmail < ActiveRecord::Migration[7.2]\n  disable_ddl_transaction!\n  def change\n    add_index :users, :email, unique: true, algorithm: :concurrently\n  end\nend",
          node_code: "// prisma/migrations/.../migration.sql\nCREATE UNIQUE INDEX CONCURRENTLY users_email_idx ON users (email);",
          nest_code: "export class AddUsersEmailIdx123 implements MigrationInterface {\n  async up(queryRunner: QueryRunner) {\n    await queryRunner.query(`CREATE UNIQUE INDEX CONCURRENTLY \"users_email_idx\" ON \"users\" (\"email\")`);\n  }\n  async down(queryRunner: QueryRunner) {\n    await queryRunner.query(`DROP INDEX CONCURRENTLY \"users_email_idx\"`);\n  }\n}",
          category: "ORM"
        },
        {
          title: "Mailers",
          slug: "mailers",
          rails_concept: "ActionMailer classes deliver emails via deliver_later / deliver_now.",
          rails_explanation: "Views under app/views; use ActiveJob for async. Preview with mailer previews.",
          node_equivalent: "Nodemailer / SES SDK called from workers.",
          nest_equivalent: "@nestjs-modules/mailer or custom MailService + queue processor.",
          rails_code: "class UserMailer < ApplicationMailer\n  def welcome(user)\n    @user = user\n    mail(to: user.email, subject: 'Welcome')\n  end\nend\nUserMailer.welcome(user).deliver_later",
          node_code: "await transporter.sendMail({ to: user.email, subject: 'Welcome', html });",
          nest_code: "@Injectable() export class MailService {\n  constructor(private mailer: MailerService) {}\n  welcome(user: User) {\n    return this.mailer.sendMail({ to: user.email, subject: 'Welcome', template: 'welcome', context: { user } });\n  }\n}",
          category: "Mail"
        },
        {
          title: "Engines",
          slug: "engines",
          rails_concept: "Mountable Rails engines package isolated routes/models (e.g. Devise).",
          rails_explanation: "Isolate namespace; mount Engine => '/path'. Share or isolate ActiveRecord.",
          node_equivalent: "Internal packages / npm workspaces mounted as sub-apps.",
          nest_equivalent: "Nest dynamic modules or separate apps in a monorepo imported as libraries.",
          rails_code: "# gemspec engine\nmount Billing::Engine => '/billing'",
          node_code: "app.use('/billing', billingApp);",
          nest_code: "@Module({ imports: [BillingModule.register({ stripeKey })] })\nexport class AppModule {}",
          category: "Architecture"
        },
        {
          title: "Current Attributes",
          slug: "current-attributes",
          rails_concept: "ActiveSupport::CurrentAttributes for per-request globals (Current.user).",
          rails_explanation: "Set in around_action; automatically reset between requests. Avoid hiding dependencies too deeply.",
          node_equivalent: "AsyncLocalStorage for request context.",
          nest_equivalent: "REQUEST-scoped providers or ALS-based context service.",
          rails_code: "class Current < ActiveSupport::CurrentAttributes\n  attribute :user, :request_id\nend\n# application_controller\naround_action { |_, b| Current.set(user: current_user, &b) }",
          node_code: "const als = new AsyncLocalStorage();\nals.run({ userId }, () => next());\nconst ctx = als.getStore();",
          nest_code: "@Injectable({ scope: Scope.REQUEST }) export class RequestContext {\n  userId?: string;\n}\n// set in middleware/guard, inject into services",
          category: "Architecture"
        },
        {
          title: "Pundit / Policy Authorization",
          slug: "pundit-policies",
          rails_concept: "Policy objects authorize? actions per user/resource.",
          rails_explanation: "ApplicationPolicy#show?/update?; authorize @post in controllers; scopes for index.",
          node_equivalent: "CASL or hand-rolled policy functions.",
          nest_equivalent: "Guards + CASL or custom PolicyService checked in guards/services.",
          rails_code: "class PostPolicy < ApplicationPolicy\n  def update? = user.admin? || record.author_id == user.id\nend\nauthorize @post",
          node_code: "function canUpdatePost(user, post) {\n  return user.role === 'admin' || post.authorId === user.id;\n}",
          nest_code: "@Injectable() export class PostsPolicy {\n  update(user: AuthUser, post: Post) {\n    return user.role === 'admin' || post.authorId === user.userId;\n  }\n}\n@UseGuards(PoliciesGuard) @CheckPolicies((a, p) => a.posts.update(a.user, p))",
          category: "Auth"
        },
        {
          title: "N+1 and Includes",
          slug: "n-plus-one-includes",
          rails_concept: "includes/preload/eager_load to avoid N+1 association queries.",
          rails_explanation: "Bullet gem detects N+1. includes chooses preload vs join; eager_load forces LEFT OUTER JOIN.",
          node_equivalent: "Prisma include/select; DataLoader for GraphQL.",
          nest_equivalent: "relations: [] / leftJoinAndSelect; avoid find in loops.",
          rails_code: "Post.includes(:author, :tags).limit(20)",
          node_code: "prisma.post.findMany({ include: { author: true, tags: true }, take: 20 })",
          nest_code: "this.posts.find({ relations: ['author', 'tags'], take: 20 });\n// or QB: .leftJoinAndSelect('post.author', 'author')",
          category: "Performance"
        },
        {
          title: "Rails Credentials / Secrets",
          slug: "rails-credentials",
          rails_concept: "Encrypted credentials.yml.enc edited with EDITOR=vim bin/rails credentials:edit.",
          rails_explanation: "Rails.application.credentials.dig(:aws, :secret_key). Master key in ENV or key file — never commit master key.",
          node_equivalent: "dotenv / sealed secrets / cloud secret managers.",
          nest_equivalent: "ConfigModule with env validation (Joi); inject ConfigService; secrets from vault in prod.",
          rails_code: "Rails.application.credentials.stripe[:secret_key]",
          node_code: "const key = process.env.STRIPE_SECRET_KEY;\nif (!key) throw new Error('missing STRIPE_SECRET_KEY');",
          nest_code: "ConfigModule.forRoot({ validationSchema: Joi.object({ STRIPE_SECRET_KEY: Joi.string().required() }) });\nthis.config.get<string>('STRIPE_SECRET_KEY');",
          category: "Config"
        },
        {
          title: "Rack Attack / Rate Limiting",
          slug: "rack-attack-rate-limiting",
          rails_concept: "Rack::Attack throttles by IP/path using Redis/memory store.",
          rails_explanation: "throttle('logins/ip', limit: 5, period: 20.seconds). Blocklists and safelists.",
          node_equivalent: "express-rate-limit + Redis store.",
          nest_equivalent: "@nestjs/throttler guards or custom Redis token-bucket middleware.",
          rails_code: "Rack::Attack.throttle('logins/ip', limit: 5, period: 20) { |req| req.ip if req.path == '/login' && req.post? }",
          node_code: "rateLimit({ windowMs: 20_000, max: 5, standardHeaders: true })",
          nest_code: "ThrottlerModule.forRoot([{ ttl: 20_000, limit: 5 }]);\n@Throttle({ default: { limit: 5, ttl: 20000 } }) @Post('login') login() {}",
          category: "Security"
        },
        {
          title: "ActiveStorage Uploads",
          slug: "activestorage-uploads",
          rails_concept: "has_one_attached / has_many_attached for files to disk/S3.",
          rails_explanation: "Direct uploads, variants for images, purge_later. Analyze content types.",
          node_equivalent: "Multer + S3 SDK; signed URLs for direct upload.",
          nest_equivalent: "FileInterceptor + S3 service; presigned POST/PUT endpoints.",
          rails_code: "has_one_attached :avatar\nuser.avatar.attach(params[:avatar])\nurl_for(user.avatar.variant(resize_to_limit: [200, 200]))",
          node_code: "const url = await s3.getSignedUrlPromise('putObject', { Bucket, Key, Expires: 900 });",
          nest_code: "@Post('avatar') @UseInterceptors(FileInterceptor('file'))\nupload(@UploadedFile() file: Express.Multer.File, @CurrentUser() user) {\n  return this.uploads.putAvatar(user.id, file);\n}",
          category: "Uploads"
        },
        {
          title: "Rake Tasks vs Nest Commands",
          slug: "rake-tasks",
          rails_concept: "lib/tasks/*.rake for ops scripts invoked via bin/rails task:name.",
          rails_explanation: "Load :environment dependency; keep idempotent; prefer jobs for heavy work.",
          node_equivalent: "node scripts/*.ts or npm run scripts.",
          nest_equivalent: "Nest Commander / custom bootstrap scripts importing AppModule.",
          rails_code: "namespace :users do\n  task backfill_slugs: :environment do\n    User.find_each { |u| u.update!(slug: u.name.parameterize) if u.slug.blank? }\n  end\nend",
          node_code: "// scripts/backfill-slugs.ts\nawait prisma.user.findMany(...)",
          nest_code: "@Command({ name: 'users:backfill-slugs' }) export class BackfillSlugs {\n  async run() { /* use injected services */ }\n}",
          category: "Ops"
        },
        {
          title: "I18n Locale Handling",
          slug: "i18n-locale",
          rails_concept: "I18n.t with locale from Accept-Language or user preference.",
          rails_explanation: "around_action set locale; YAML under config/locales. Lazy lookup in views.",
          node_equivalent: "i18next middleware.",
          nest_equivalent: "nestjs-i18n module resolving lang from header/query.",
          rails_code: "I18n.with_locale(current_user.locale) { I18n.t('errors.not_found') }",
          node_code: "req.t('errors.not_found')",
          nest_code: "constructor(private i18n: I18nService) {}\nthis.i18n.t('errors.not_found', { lang: ctx.lang });",
          category: "I18n"
        },
        {
          title: "Hotwire / Turbo vs SPA APIs",
          slug: "hotwire-vs-spa",
          rails_concept: "Server-rendered HTML + Turbo Streams vs JSON API for SPAs.",
          rails_explanation: "Rails often ships HTML-first. Nest/Node backends typically expose JSON for React/Vue clients.",
          node_equivalent: "JSON REST/GraphQL backends; SSR optional (Next).",
          nest_equivalent: "REST/GraphQL modules; no Turbo — contract is OpenAPI/JSON.",
          rails_code: "respond_to do |format|\n  format.html\n  format.turbo_stream\n  format.json { render json: @post }\nend",
          node_code: "res.json(post);",
          nest_code: "@Get(':id') find(@Param('id') id: string) { return this.posts.findOne(id); } // JSON by default",
          category: "APIs"
        }
      ]
    end
  end
end
