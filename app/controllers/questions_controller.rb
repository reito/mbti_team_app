class QuestionsController < ApplicationController
  def index
    @questions = Question.page(params[:page]).per(10)
  end

  def submit
    # 現在のページの回答をセッションに保存
    session[:answers] ||= {}
    session[:answers].merge!(params[:answers]) if params[:answers]

    # 最後のページかどうかを確認
    if params[:page].to_i >= Question.count / 10
      # 最終ページなら、全ての回答を処理
      process_answers(session[:answers])
      redirect_to result_questions_path
    else
      # 次のページにリダイレクト
      redirect_to questions_path(page: params[:page].to_i + 1)
    end
  end

  def result
    # セッションからMBTI診断結果を取得して表示
    @mbti_result = session[:mbti_result]
  end

  private

  def process_answers(answers)
    # 回答をフォーマット
    formatted_answers = format_answers(answers)

    # OpenAI APIを使ってMBTI結果を生成
    response = OpenAI::Completion.create(
      engine: "text-davinci-003",
      prompt: "Given the following MBTI questionnaire responses: #{formatted_answers}, determine the user's MBTI type and suggest an ideal team composition and roles.",
      max_tokens: 300
    )

    # OpenAIから受け取った結果をセッションに保存
    session[:mbti_result] = response.choices.first.text.strip
  end
end
