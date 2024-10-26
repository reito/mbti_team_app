class QuestionsController < ApplicationController
  def index
    @questions = Question.page(params[:page]).per(10)
  end

  def submit
    # 現在のページの回答をセッションに保存
    session[:answers] ||= {}
    session[:answers].merge!(answers_params) if answers_params.present?

    # 最後のページかどうかを確認
    if params[:page].to_i >= (Question.count / 10.0).ceil
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

  def answers_params
    # answers パラメータを許可
    params.require(:answers).permit!
  end

  def process_answers(answers)
    # 回答をフォーマット
    formatted_answers = format_answers(answers)

    # OpenAI APIを使ってMBTI結果を生成
    client = OpenAI::Client.new
    response = client.completions(
      parameters: {
        model: "text-davinci-003",
        prompt: "以下のMBTI質問回答に基づいて、ユーザーのMBTIタイプを判定し、理想的なチーム編成と役割を提案してください: #{formatted_answers}",
        max_tokens: 300
      }
    )

    # OpenAIから受け取った結果をセッションに保存
    session[:mbti_result] = response.choices.first.text.strip
  end

  def format_answers(answers)
    # 回答を読みやすい形にフォーマット
    answers.map { |question_id, answer| "Question #{question_id}: Answer #{answer}" }.join("\n")
  end
end
