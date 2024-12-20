/**
 * Converts markdown to plain text, but retains ordered and unordered lists.
 *
 * @param {string} markdown - The markdown.
 * @param {number} maxCharacterLimit - Maximum character limit.
 * @returns {string | null} The markdown converted to plaintext, or null if no markdown is specified.
 */
function convertMarkdownToPlainText(markdown, maxCharacterLimit = 500) {
  let charCount = 0;
  let lines;
  let plainText;
  let truncatedText = '';

  if (!markdown) {
    console.log('no makrdown specified');

    return null;
  }

  // remove markdown links [text](url) -> text
  plainText = markdown.replace(/\[([^\]]+)\]\([^)]+\)/g, '$1');
  // remove headers (e.g., # Header) -> Header
  plainText = plainText.replace(/^#{1,6}\s*(.*)/gm, '$1');
  // remove bold and italic (e.g., **bold** or _italic_) -> bold or italic
  plainText = plainText.replace(/(\*\*|__)(.*?)\1/g, '$2');
  plainText = plainText.replace(/(\*|_)(.*?)\1/g, '$2');
  // remove inline code (`code`) and code blocks (```) -> code
  plainText = plainText.replace(/`([^`]+)`/g, '$1');
  plainText = plainText.replace(/```[\s\S]*?```/g, '');
  // remove multiple blank lines
  plainText = plainText.replace(/\n\s*\n+/g, '\n\n');

  // split the text
  lines = plainText.split('\n');

  // truncate
  for (const line of lines) {
    if (charCount + line.length > maxCharacterLimit) {
      break;
    }

    truncatedText += (truncatedText ? '\n' : '') + line;
    charCount += line.length + 1;
  }

  return truncatedText;
}

export default convertMarkdownToPlainText;
